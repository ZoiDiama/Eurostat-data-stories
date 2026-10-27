# Case study 04 · Early leavers from education and training in the EU
# Original Eurostat news item (24 June 2021): the share of early leavers fell from
# 13.8% in 2010 to 9.9% in 2020; the EU aims to bring it below 9% by 2030.
# Young men left school early more often than young women in almost every country.
# This script compares young men and young women in each country in the latest
# year, against the 2030 target.
#
# Data: Eurostat, edat_lfse_14 (Early leavers from education and training by sex
# and labour status). People aged 18-24, % of the population. Spreadsheet download
# from the Eurostat data browser: Sheet 6 = males, Sheet 11 = females
# (labour status "Population").

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/04-early-school-leavers/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_esl <- "edat_lfse_14__custom_23689854_spreadsheet.xlsx"   # in this folder
yr       <- "2025"   # latest year
target   <- 9        # EU 2030 target: below 9%

if (!file.exists(file_esl)) stop("File not found: ", file_esl, "\nWorking directory is: ",
                                 getwd(), "\nSet the working directory to this script's ",
                                 "folder, or change the file name in section 0.")

# 1. LIBRARIES -------------------------------------------------------------
pkgs <- c("tidyverse", "readxl", "showtext", "ggtext", "ggrepel")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

library(tidyverse)
library(readxl)
library(showtext)
library(ggtext)
library(ggrepel)

font_add_google("Poppins", "poppins")   # needs internet the first time
showtext_auto()
showtext_opts(dpi = 288)
fam <- "poppins"

# 2. DATA ------------------------------------------------------------------
# Each sheet: 10 header rows, then a row "TIME" with the years. Each year has a value
# column followed by a flag column (u = low reliability, d = definition differs).
read_year <- function(sheet, y) {
  raw <- read_excel(file_esl, sheet = sheet, skip = 10, col_names = FALSE,
                    col_types = "text")
  j <- which(unlist(raw[1, ]) == y)
  raw[-(1:2), ] |>
    transmute(geo  = .data[[names(raw)[1]]],
              val  = parse_number(.data[[names(raw)[j]]], na = ":"),
              flag = replace_na(.data[[names(raw)[j + 1]]], "")) |>
    filter(!is.na(geo))
}

eu27 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland",
          "Greece", "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia", "Lithuania",
          "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal",
          "Romania", "Slovenia", "Slovakia", "Finland", "Sweden")
eu_name <- "European Union - 27 countries (from 2020)"

esl <- read_year("Sheet 6", yr) |> rename(men = val, flag_m = flag) |>
  inner_join(read_year("Sheet 11", yr) |> rename(women = val, flag_w = flag), by = "geo") |>
  filter(geo %in% c(eu27, eu_name))

no_data <- esl |> filter(is.na(men) | is.na(women)) |> pull(geo)     # Luxembourg
esl <- esl |> filter(!is.na(men), !is.na(women))

# EU total, both sexes (Sheet 1)
eu_total <- read_year("Sheet 1", yr) |> filter(geo == eu_name) |> pull(val)   # 9.1

# 3. GROUPS ----------------------------------------------------------------
esl <- esl |>
  mutate(is_eu = geo == eu_name,
         flags = paste(flag_m, flag_w),
         name  = case_when(is_eu ~ "EU-27",
                           str_detect(flags, "u") ~ paste0(geo, "†"),   # † low reliability
                           str_detect(flags, "d") ~ paste0(geo, "*"),        # * definition differs
                           TRUE ~ geo),
         group = case_when(is_eu ~ "eu",
                           women < target & men >= target ~ "women_only",
                           women < target & men <  target ~ "both_below",
                           TRUE ~ "other"),
         area  = case_when(men <  target & women <  target ~ "both_below",
                           men >= target & women >= target ~ "both_above",
                           TRUE ~ "mixed"))

ctry       <- esl |> filter(!is_eu)
eu         <- esl |> filter(is_eu)
n_ctry     <- nrow(ctry)                                   # 26
n_men_above   <- sum(ctry$men   >= target)                 # 14
n_women_above <- sum(ctry$women >= target)                 # 6
# the title says the EU is close to the target and young men hold it back
stopifnot(eu_total >= target, eu_total - target < 0.5,
          eu$men >= target, eu$women < target, n_men_above > n_ctry / 2)

# 4. COLOURS & TEXT --------------------------------------------------------
# Areas: green = both below the target, red = both above, amber = one below, one above
fill_both_below <- "#F1F8F1"; text_both_below <- "#2E7D32"
fill_both_above <- "#FCF0F0"; text_both_above <- "#B23A3A"
fill_mixed      <- "#FDF7EA"; text_mixed      <- "#9A6400"
dot   <- "#4A4A4A"    # country labels
# dots take the colour of their area's label
ink   <- "#1A1A1A"; muted <- "#5A5A5A"; faint <- "#7A7A7A"; grid <- "#E6E6E6"

tt <- "The EU is close to its 2030 school target, but young men are holding it back"

st <- paste0(
  "Early leavers from education and training, % of people aged 18–24. In ", yr, " the EU ",
  "stood at ", format(eu_total, nsmall = 1), "%, just above the 2030 target of below ",
  target, "% (young men ", format(eu$men, nsmall = 1), "%, young women ",
  format(eu$women, nsmall = 1), "%). Young men are above it in ",
  "**", n_men_above, " of ", n_ctry, " countries**, young women in ", n_women_above, ".")

ct <- paste0("† Low reliability. * Definition differs. ",
             if (length(no_data) > 0) paste0("No ", yr, " data for ",
                                              paste(no_data, collapse = ", "), ". ") else "",
             "Break in series in 2021 for all countries and in ", yr, " for Denmark.<br>",
             "Data source: Eurostat, edat_lfse_14 · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
lim <- ceiling(max(c(esl$men, esl$women)) / 2) * 2         # 18

p <- ggplot(esl, aes(men, women)) +
  # four areas split by the target
  annotate("rect", xmin = 0, xmax = target, ymin = 0, ymax = target, fill = fill_both_below) +
  annotate("rect", xmin = target, xmax = lim, ymin = target, ymax = lim, fill = fill_both_above) +
  annotate("rect", xmin = target, xmax = lim, ymin = 0, ymax = target, fill = fill_mixed) +
  annotate("rect", xmin = 0, xmax = target, ymin = target, ymax = lim, fill = fill_mixed) +
  annotate("text", x = target - 0.2, y = 0.4, hjust = 1, vjust = 0, family = fam, size = 2.5,
           colour = text_both_below, fontface = "bold", lineheight = 0.95,
           label = "Both below\nthe target") +
  annotate("text", x = lim - 0.2, y = lim - 2.2, hjust = 1, vjust = 1, family = fam, size = 2.5,
           colour = text_both_above, fontface = "bold", lineheight = 0.95,
           label = "Both above\nthe target") +
  annotate("text", x = lim - 0.2, y = 0.4, hjust = 1, vjust = 0, family = fam, size = 2.5,
           colour = text_mixed, fontface = "bold", lineheight = 0.95,
           label = "Women below the target,\nmen above") +
  annotate("text", x = 0.4, y = target + 0.3, hjust = 0, vjust = 0, family = fam, size = 2.5,
           colour = text_mixed, fontface = "bold", lineheight = 0.95,
           label = "Men below the target,\nwomen above") +
  # 2030 target lines
  geom_vline(xintercept = target, colour = muted, linewidth = 0.4, linetype = "22") +
  geom_hline(yintercept = target, colour = muted, linewidth = 0.4, linetype = "22") +
  annotate("text", x = target + 0.15, y = lim, hjust = 0, vjust = 1, family = fam,
           size = 2.3, colour = muted, label = paste0("2030 target: below ", target, "%")) +
  # countries and the EU
  geom_point(data = ctry, aes(fill = area), shape = 21, colour = "white", stroke = 0.3,
             size = 2.6) +
  scale_fill_manual(values = c(both_below = text_both_below, both_above = text_both_above,
                               mixed = text_mixed), guide = "none") +
  geom_point(data = eu, colour = ink, size = 3.2, shape = 18) +
  geom_text_repel(aes(label = name, colour = group,
                      fontface = if_else(is_eu, "bold", "plain")),
                  family = fam, size = 2.3, seed = 3, box.padding = 0.35,
                  point.padding = 0.25, min.segment.length = 0.2, segment.size = 0.2,
                  segment.colour = "#BDBDBD", max.overlaps = Inf) +
  scale_colour_manual(values = c(women_only = dot, both_below = dot, other = dot,
                                 eu = ink), guide = "none") +
  scale_x_continuous(limits = c(0, lim), breaks = seq(0, lim, 3),
                     labels = \(x) paste0(x, "%"), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, lim), breaks = seq(0, lim, 3),
                     labels = \(x) paste0(x, "%"), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = tt, subtitle = st, caption = ct,
       x = "Young men, % early leavers", y = "Young women, % early leavers") +
  theme_minimal(base_family = fam) +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.title = element_textbox_simple(face = "bold", size = 22, colour = ink,
                                        lineheight = 1.1, margin = margin(b = 12)),
    plot.subtitle = element_textbox_simple(size = 10.5, colour = muted,
                                           lineheight = 1.3, margin = margin(b = 14)),
    plot.caption = element_textbox_simple(size = 7, colour = faint,
                                          lineheight = 1.4, margin = margin(t = 14)),
    axis.title = element_text(size = 8, colour = muted),
    axis.title.x = element_text(margin = margin(t = 8)),
    axis.title.y = element_text(margin = margin(r = 8)),
    axis.text = element_text(size = 8, colour = faint),
    panel.grid = element_blank(),
    panel.grid.major = element_line(colour = grid, linewidth = 0.3),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 6. SAVE ------------------------------------------------------------------
ggsave("early-school-leavers.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
