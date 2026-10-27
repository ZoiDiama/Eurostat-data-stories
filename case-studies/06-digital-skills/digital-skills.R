# Case study 06 · Digital skills in the EU and the 2030 target
# Original Eurostat news item (14 May 2020): in 2019, people living with children had
# better digital skills than people living without children (EU: 64% vs 53% with
# basic or above basic digital skills).
# This script shows, for every EU country, how far the whole adult population is from
# the EU 2030 target: 80% of people aged 16-74 with at least basic digital skills.
#
# Data: Eurostat, isoc_sk_dskl_i21 (Individuals' level of digital skills, from 2021
# onwards). Spreadsheet download from the Eurostat data browser. Sheet 23 = all
# individuals, basic or above basic overall digital skills, % of individuals.

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/06-digital-skills/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_dsk <- "../../data/isoc_sk_dskl_i21.xlsx"
sheet    <- "Sheet 23"
y0       <- "2021"   # first year of the new indicator
y1       <- "2025"   # latest year
target   <- 80       # EU 2030 target: 80% with at least basic digital skills

if (!file.exists(file_dsk)) stop("File not found: ", file_dsk, "\nWorking directory is: ",
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
# Check that the sheet is the right one: all individuals, basic or above basic
# overall digital skills, % of individuals
info <- read_excel(file_dsk, sheet = sheet, range = "A6:C8", col_names = FALSE)
info <- setNames(info[[3]], info[[1]])
stopifnot(info[["Individual type"]] == "All individuals",
          str_starts(info[["Information society indicator"]],
                     "Individuals with basic or above basic overall digital skills"),
          info[["Unit of measure"]] == "Percentage of individuals")

# 9 header rows, then a row "TIME" with the years. Each year has a value column
# followed by a flag column.
raw <- read_excel(file_dsk, sheet = sheet, skip = 9, col_names = FALSE, col_types = "text")
hdr <- unlist(raw[1, ])

eu27 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland",
          "Greece", "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia", "Lithuania",
          "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal",
          "Romania", "Slovenia", "Slovakia", "Finland", "Sweden")
eu_name <- "European Union - 27 countries (from 2020)"

dsk <- raw[-(1:2), ] |>
  filter(.data[[names(raw)[1]]] %in% c(eu27, eu_name)) |>
  transmute(geo = .data[[names(raw)[1]]],
            v0  = parse_number(.data[[names(raw)[which(hdr == y0)]]], na = ":"),
            v1  = parse_number(.data[[names(raw)[which(hdr == y1)]]], na = ":"),
            f1  = replace_na(.data[[names(raw)[which(hdr == y1) + 1]]], ""))

stopifnot(all(eu27 %in% dsk$geo), !anyNA(dsk$v0), !anyNA(dsk$v1))

eu      <- dsk |> filter(geo == eu_name)                     # 53.9 -> 60.4
ctry    <- dsk |> filter(geo != eu_name)
n_reach <- sum(ctry$v1 >= target)                            # 4
n_up    <- sum(ctry$v1 > ctry$v0)
# the title says only a few countries have reached the target
stopifnot(eu$v1 < target, n_reach >= 1, n_reach <= 5)

# 3. ORDER -----------------------------------------------------------------
rows <- dsk |>
  mutate(is_eu   = geo == eu_name,
         name    = case_when(is_eu ~ "EU-27",
                             f1 != "" ~ paste0(geo, "*"),
                             TRUE ~ geo),
         name    = fct_reorder(name, v1),
         reached = v1 >= target)

# 4. COLOURS & TEXT --------------------------------------------------------
c_done  <- "#1F7A80"    # dark teal: target reached
c_todo  <- "#8CC3C6"    # light teal: not yet
c_todo_txt <- "#5E9EA2" # darker shade of light teal, for text
c_track <- "#EDEDED"    # empty part of the bar
ink     <- "#1A1A1A"; muted <- "#5A5A5A"; faint <- "#7A7A7A"; grid <- "#E6E6E6"

tt <- paste0("In ", y1, ", only ", n_reach, " EU countries had reached the 2030 ",
             "digital skills target")

st <- paste0(
  "People aged 16–74 with basic or above basic digital skills, % in ", y1, ". ",
  "The EU's 2030 target is ", target, "%. In the EU the share rose from ",
  format(eu$v0, nsmall = 1, digits = 3), "% in ", y0, " to ",
  format(eu$v1, nsmall = 1, digits = 3), "%. <span style='color:", c_done, "'>**",
  n_reach, " countries**</span> have reached the target; ",
  "<span style='color:", c_todo_txt, "'>**", 27 - n_reach, "**</span> have not. ",
  "The black tick on each bar shows ", y0, ".")

ct <- paste0("Data for ", y0, ", 2023 and ", y1, " use the same method; earlier years ",
             "(until 2019) used a different indicator and are not comparable.<br>",
             "Data source: Eurostat, isoc_sk_dskl_i21 · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
bar <- 3.2   # bar thickness

p <- ggplot(rows, aes(y = name)) +
  # empty track, 0-100%
  geom_segment(aes(x = 0, xend = 100, yend = name), colour = c_track,
               linewidth = bar, lineend = "round") +
  # filled part, up to the latest year
  geom_segment(aes(x = 0, xend = v1, yend = name, colour = reached),
               linewidth = bar, lineend = "round") +
  # 2021 tick
  geom_tile(aes(x = v0, width = 0.45, height = 0.55), fill = ink) +
  # 2030 target
  annotate("segment", x = target, xend = target, y = 0.4, yend = nrow(rows) + 0.6,
           colour = muted, linewidth = 0.4, linetype = "22") +
  annotate("text", x = target, y = nrow(rows) + 1, label = paste0("2030 target: ", target, "%"),
           family = fam, size = 2.4, colour = muted, vjust = 0) +
  # values at the end of each bar
  geom_text(aes(x = 103, label = format(round(v1, 1), nsmall = 1),
                fontface = if_else(is_eu, "bold", "plain")),
            colour = if_else(rows$reached, c_done, muted),
            hjust = 0, family = fam, size = 2.4) +
  scale_colour_manual(values = c(`TRUE` = c_done, `FALSE` = c_todo), guide = "none") +
  scale_y_discrete(labels = \(x) if_else(x == "EU-27", "**EU-27**", x),
                   expand = expansion(add = c(0.6, 1.6))) +
  scale_x_continuous(limits = c(-1.5, 110), breaks = seq(0, 100, 20),
                     expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
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
    axis.text.x = element_blank(),                         # values are on the bars
    axis.text.y = element_markdown(size = 8, colour = ink, hjust = 1),
    panel.grid = element_blank(),
    panel.grid.major.x = element_line(colour = grid, linewidth = 0.3),   # light guides every 20%
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 6. SAVE ------------------------------------------------------------------
ggsave("digital-skills.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
