# Case study 02 · Tourism nights in the EU after the pandemic
# Original Eurostat news item (16 July 2020): nights spent at EU tourist
# accommodation dropped sharply in March and April 2020.
# This script follows the story to December 2025, comparing each month with
# the same month of 2019, for domestic and foreign tourists.
#
# Data: Eurostat, tour_occ_nim (Nights spent at tourist accommodation
# establishments - monthly data). Unit: percentage change compared to same month
# in 2019. EU-27 (2020); hotels, holiday and other short-stay accommodation,
# camping grounds (I551-I553); by country of residence of the guest.
# Spreadsheet download from the Eurostat data browser. Sheet 1 is the original
# Eurostat table; the tab "Data" holds the same values as a clean table
# (month, domestic, foreign), January 2020 - December 2025.

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/02-tourism/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_tour <- "../../data/tour_occ_nim_vs2019.xlsx"

if (!file.exists(file_tour)) stop("File not found: ", file_tour, "\nWorking directory is: ",
                                  getwd(), "\nSet the working directory to this script's ",
                                  "folder, or change the file name in section 0.")

# 1. LIBRARIES -------------------------------------------------------------
pkgs <- c("tidyverse", "readxl", "lubridate", "showtext", "ggtext")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

library(tidyverse)
library(readxl)
library(lubridate)
library(showtext)
library(ggtext)

font_add_google("Poppins", "poppins")   # needs internet the first time
showtext_auto()
showtext_opts(dpi = 288)
fam <- "poppins"

# 2. DATA ------------------------------------------------------------------
# Tab "Data": one row per month. Values are % change compared with the same
# month in 2019 (e.g. -92.62 = 92.62% fewer nights than in April 2019).
tour <- read_excel(file_tour, sheet = "Data") |>
  rename(month = 1, Domestic = 2, Foreign = 3) |>
  pivot_longer(-month, names_to = "resid", values_to = "change") |>
  mutate(month = ym(month),
         pct   = 100 + change)                 # 100 = same as the same month in 2019

# 3. WRANGLING -------------------------------------------------------------
last      <- max(tour$month)
last_year <- year(last)
change_at <- \(r, mth) tour$change[tour$resid == r & tour$month == ym(mth)]

# The crash and the first summer
dom_apr20 <- change_at("Domestic", "2020-04")   # -92.62
for_apr20 <- change_at("Foreign",  "2020-04")   # -98.38
dom_aug20 <- change_at("Domestic", "2020-08")   # -2.99
for_aug20 <- change_at("Foreign",  "2020-08")   # -60.49

# First month back above 2019 after the crash (from March 2020 on)
first_above <- tour |>
  filter(month >= ym("2020-03"), change > 0) |>
  group_by(resid) |>
  summarise(month = min(month))
first_at <- \(r) format(first_above$month[first_above$resid == r], "%B %Y")
# Domestic: July 2021 · Foreign: February 2023

# Latest year: in how many months foreign nights grew more than domestic nights
gap <- tour |>
  filter(year(month) == last_year) |>
  select(month, resid, change) |>
  pivot_wider(names_from = resid, values_from = change)
for_ahead <- sum(gap$Foreign > gap$Domestic)                     # 11 of 12
stopifnot(nrow(gap) == 12, for_ahead >= 7)                       # "most months" must hold

# Labels at the end of each line
ends <- tour |> filter(month == last) |>
  mutate(label = paste0("**", resid, "**<br>", round(pct)))

# 4. COLOURS & TEXT --------------------------------------------------------
cols  <- c("Domestic" = "#E07A1F", "Foreign" = "#1F7A80")
ink   <- "#1A1A1A"
muted <- "#5A5A5A"
faint <- "#7A7A7A"
grid  <- "#E6E6E6"

# Draft title: Zoi to rewrite
tt <- "After COVID, EU domestic tourism recovered first, but foreign grew more"

st <- paste0(
  "Nights spent at EU tourist accommodation, as % of the same month in 2019 ",
  "(100 = same as 2019). In August 2020 <span style='color:", cols["Domestic"],
  "'>**domestic**</span> nights were only ", round(-dom_aug20), "% below 2019, ",
  "<span style='color:", cols["Foreign"], "'>**foreign**</span> nights ",
  round(-for_aug20), "% below. Domestic tourism passed its 2019 level in ",
  first_at("Domestic"), ", foreign tourism in ", first_at("Foreign"), ". In ", last_year,
  " foreign nights grew more than domestic ones in ", for_ahead, " of 12 months.")

ct <- paste0("EU-27 (2020). Hotels, holiday and other short-stay accommodation, camping grounds. ",
             "Data to ", format(last, "%B %Y"), ". Easter falls in March or April, ",
             "so those months move up and down.<br>",
             "Data source: Eurostat, tour_occ_nim · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
p <- ggplot(tour, aes(month, pct, colour = resid)) +
  geom_hline(yintercept = 100, colour = faint, linewidth = 0.4) +
  annotate("text", x = last + days(40), y = 100, label = "Same month in 2019", hjust = 0,
           vjust = -0.5, family = fam, size = 2.4, colour = faint) +
  geom_line(linewidth = 1) +
  geom_point(data = filter(tour, month == last), size = 2) +
  geom_richtext(data = ends, aes(x = last + days(40), y = pct, label = label), hjust = 0,
                family = fam, size = 2.6, fill = NA, label.colour = NA,
                lineheight = 1.1, show.legend = FALSE) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_date(breaks = seq(ym("2020-01"), floor_date(last, "year"), by = "1 year"),
               date_labels = "%Y",
               expand = expansion(add = c(20, 330))) +
  scale_y_continuous(limits = c(0, 131), breaks = seq(0, 125, 25), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = tt, subtitle = st, caption = ct, x = NULL,
       y = "% of the same month in 2019") +
  theme_minimal(base_family = fam) +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.title = element_textbox_simple(face = "bold", size = 22, colour = ink,
                                        lineheight = 1.1, margin = margin(b = 12)),
    plot.subtitle = element_textbox_simple(size = 10.5, colour = muted,
                                           lineheight = 1.3, margin = margin(b = 16)),
    plot.caption = element_textbox_simple(size = 7, colour = faint,
                                          lineheight = 1.4, margin = margin(t = 16)),
    axis.title.y = element_text(size = 8, colour = muted, angle = 90, margin = margin(r = 8)),
    axis.text = element_text(size = 8, colour = faint),
    panel.grid = element_blank(),
    panel.grid.major.y = element_line(colour = grid, linewidth = 0.3),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 6. SAVE ------------------------------------------------------------------
ggsave("tourism.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
