# Case study 05 · Deaths from influenza in the EU before, during and after COVID
# Original Eurostat news item (7 April 2020): in 2016, 4 186 people died from influenza
# in the EU, a standardised rate of 9 deaths per million inhabitants (0.93 per 100 000).
# This script shows the rate for every EU country and every year from 2011 to 2023.
#
# Data: Eurostat, hlth_cd_asdr2 (Causes of death - standardised death rate by NUTS 2
# region of residence). Country level. Spreadsheet download from the Eurostat data
# browser. Sheet 5 = Influenza (including swine flu) (J09-J11), total (both sexes),
# all ages, rate per 100 000 inhabitants, age-standardised.

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/05-influenza/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_flu <- "../../data/hlth_cd_asdr2.xlsx"
sheet    <- "Sheet 5"
y_low    <- "2021"   # the year flu deaths almost vanished
y_before <- "2019"   # the last year before COVID
y_last   <- "2023"   # latest year
y_news   <- "2016"   # year in my news item

if (!file.exists(file_flu)) stop("File not found: ", file_flu, "\nWorking directory is: ",
                                 getwd(), "\nSet the working directory to this script's ",
                                 "folder, or change the file name in section 0.")

# 1. LIBRARIES -------------------------------------------------------------
pkgs <- c("tidyverse", "readxl", "showtext", "ggtext")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

library(tidyverse)
library(readxl)
library(showtext)
library(ggtext)

font_add_google("Poppins", "poppins")   # needs internet the first time
showtext_auto()
showtext_opts(dpi = 288)
fam <- "poppins"

# 2. DATA ------------------------------------------------------------------
# Check that the sheet is the right one: influenza, both sexes, all ages
info <- read_excel(file_flu, sheet = sheet, range = "A5:C9", col_names = FALSE)
info <- setNames(info[[3]], info[[1]])
stopifnot(str_detect(info[["International Statistical Classification of Diseases and Related Health Problems (ICD-10)"]], "Influenza"),
          info[["Sex"]] == "Total", info[["Age class"]] == "Total", info[["Unit of measure"]] == "Rate")

# 10 header rows, then a row "TIME" with the years. Each year has a value column
# followed by a flag column (d = definition differs).
raw <- read_excel(file_flu, sheet = sheet, skip = 10, col_names = FALSE, col_types = "text")
hdr <- unlist(raw[1, ])
yrs <- hdr[str_detect(hdr, "^20\\d\\d$") & !is.na(hdr)]

eu27 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland",
          "Greece", "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia", "Lithuania",
          "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal",
          "Romania", "Slovenia", "Slovakia", "Finland", "Sweden")
eu_name <- "European Union - 27 countries (from 2020)"

flu <- map_dfr(yrs, \(y) {
  j <- which(hdr == y)
  raw[-(1:2), ] |>
    filter(.data[[names(raw)[1]]] %in% c(eu27, eu_name)) |>
    transmute(geo  = .data[[names(raw)[1]]],
              year = as.integer(y),
              rate = parse_number(.data[[names(raw)[j]]], na = ":"),
              flag = replace_na(.data[[names(raw)[j + 1]]], ""))
})

stopifnot(all(eu27 %in% flu$geo), !anyNA(flu$rate))

# 3. KEY NUMBERS -----------------------------------------------------------
wide <- flu |> select(geo, year, rate) |> pivot_wider(names_from = year, values_from = rate)
eu   <- wide |> filter(geo == eu_name)
ctry <- wide |> filter(geo != eu_name)

n_lower <- sum(ctry[[y_low]] < ctry[[y_before]])           # 26 of 27 (not Bulgaria)
# the title says flu deaths almost vanished in 2021 and came back
stopifnot(eu[[y_low]] < 0.1, n_lower >= 26, eu[[y_last]] > eu[[y_news]])

# 4. ORDER -----------------------------------------------------------------
# Countries sorted by their average rate over all years (highest at the top);
# the EU in its own row above them.
ord <- flu |> filter(geo != eu_name) |> group_by(geo) |>
  summarise(avg = mean(rate)) |> arrange(avg) |> pull(geo)

flu <- flu |>
  mutate(is_eu = geo == eu_name,
         panel = if_else(is_eu, "eu", "ctry"),
         panel = factor(panel, levels = c("eu", "ctry")),
         name  = case_when(is_eu ~ "EU-27",
                           geo %in% geo[flag == "d"] ~ paste0(geo, "*"),
                           TRUE ~ geo),
         name  = factor(name, levels = c(if_else(ord %in% flu$geo[flu$flag == "d"],
                                                 paste0(ord, "*"), ord), "EU-27")))

# 5. COLOURS & TEXT --------------------------------------------------------
# one colour per band of the rate, from almost white (near zero) to dark teal
bands <- c("Under 0.1", "0.1–0.5", "0.5–1", "1–2", "2–3", "3–5", "5 or more")
pal   <- setNames(c("#F4F8F8", "#D9ECEC", "#B2D8D9", "#84BFC1", "#4F9EA2", "#1F7A80", "#0E4A4E"),
                  bands)
flu <- flu |> mutate(band = cut(rate, c(-Inf, 0.1, 0.5, 1, 2, 3, 5, Inf), labels = bands,
                                right = FALSE))
ink   <- "#1A1A1A"; muted <- "#5A5A5A"; faint <- "#7A7A7A"

fmt <- \(x) formatC(x, format = "f", digits = 2)

tt <- paste0("Flu deaths almost vanished in the EU in ", y_low, ", then came back")

st <- paste0(
  "Deaths from influenza per 100,000 inhabitants, age-standardised. The EU rate fell from ",
  fmt(eu[[y_before]]), " in ", y_before, " to <b>", fmt(eu[[y_low]]), " in ", y_low,
  "</b>, and was lower in ", n_lower, " of 27 countries. By ", y_last, " it was back at ",
  fmt(eu[[y_last]]), ", almost double the ", fmt(eu[[y_news]]), " of ", y_news, ".")

ct <- paste0("Countries sorted by their average rate, ", min(yrs), "–", max(yrs),
             ". * Definition differs in some years (Croatia 2012–13, Hungary 2011–13).<br>",
             "Data source: Eurostat, hlth_cd_asdr2 · Creator: Zoi Diamantakou")

# 6. PLOT ------------------------------------------------------------------
yr_lab <- \(x) if_else(x == as.integer(y_low), paste0("**", x, "**"), as.character(x))

p <- ggplot(flu, aes(year, name, fill = band)) +
  geom_tile(colour = "white", linewidth = 0.6) +
  # outline the year flu deaths almost vanished
  annotate("rect", xmin = as.integer(y_low) - 0.5, xmax = as.integer(y_low) + 0.5,
           ymin = -Inf, ymax = Inf, fill = NA, colour = ink, linewidth = 0.5) +
  facet_grid(panel ~ ., scales = "free_y", space = "free_y") +
  scale_fill_manual(values = pal, drop = FALSE, name = "Deaths per 100,000",
                    guide = guide_legend(nrow = 1, title.position = "left",
                                         label.position = "bottom",
                                         keywidth = unit(34, "pt"),
                                         keyheight = unit(8, "pt"))) +
  scale_x_continuous(breaks = as.integer(yrs), labels = yr_lab, position = "top",
                     expand = c(0, 0)) +
  scale_y_discrete(labels = \(x) if_else(x == "EU-27", "**EU-27**", x), expand = c(0, 0)) +
  labs(title = tt, subtitle = st, caption = ct, x = NULL, y = NULL) +
  theme_minimal(base_family = fam) +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.title = element_textbox_simple(face = "bold", size = 22, colour = ink,
                                        lineheight = 1.1, margin = margin(b = 12)),
    plot.subtitle = element_textbox_simple(size = 10.5, colour = muted,
                                           lineheight = 1.3, margin = margin(b = 10)),
    plot.caption = element_textbox_simple(size = 7, colour = faint,
                                          lineheight = 1.4, margin = margin(t = 14)),
    legend.position = "top",
    legend.justification = "left",
    legend.title = element_text(size = 7.5, colour = muted, margin = margin(r = 8)),
    legend.text = element_text(size = 7, colour = faint, margin = margin(t = 2)),
    legend.title.align = 0,
    legend.spacing.x = unit(1, "pt"),
    legend.margin = margin(0, 0, 6, 0),
    axis.text.x.top = element_markdown(size = 7.5, colour = muted),
    axis.text.y = element_markdown(size = 7.5, colour = ink, hjust = 1),
    strip.text = element_blank(),
    panel.spacing.y = unit(8, "pt"),
    panel.grid = element_blank(),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 7. SAVE ------------------------------------------------------------------
ggsave("influenza.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
