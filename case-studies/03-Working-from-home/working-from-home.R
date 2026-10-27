# Case study 03 · Working from home in the EU before and after COVID
# Original Eurostat news item (24 April 2020): in 2019, 5.4% of employed people
# in the EU usually worked from home and 9.0% sometimes did (ages 15-64).
# This script compares 2019 with 2025 for each EU country, for people who
# sometimes work from home (hybrid working).
#
# Data: Eurostat, lfsa_ehomp (Employed persons working from home by professional
# status - % of total employment). Spreadsheet download from the Eurostat data
# browser. Sheet 1 = "Sometimes", total (both sexes), 15-64 years, employed persons.

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/03-working-from-home/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_wfh <- "../../data/lfsa_ehomp.xlsx"
y0 <- "2019"   # year of my news item
y1 <- "2025"   # latest year

if (!file.exists(file_wfh)) stop("File not found: ", file_wfh, "\nWorking directory is: ",
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
# Sheet 1: 11 header rows, then a row "TIME" with the years. Each year has a value
# column followed by a flag column (b = break in series, d = definition differs).
raw <- read_excel(file_wfh, sheet = "Sheet 1", skip = 11, col_names = FALSE,
                  col_types = "text")
hdr <- unlist(raw[1, ])
col_of <- \(y) which(hdr == y)

eu27 <- c("Belgium", "Bulgaria", "Czechia", "Denmark", "Germany", "Estonia", "Ireland",
          "Greece", "Spain", "France", "Croatia", "Italy", "Cyprus", "Latvia", "Lithuania",
          "Luxembourg", "Hungary", "Malta", "Netherlands", "Austria", "Poland", "Portugal",
          "Romania", "Slovenia", "Slovakia", "Finland", "Sweden")
eu_name <- "European Union - 27 countries (from 2020)"

wfh <- raw[-1, ] |>
  transmute(geo   = .data[[names(raw)[1]]],
            v0    = parse_number(.data[[names(raw)[col_of(y0)]]], na = ":"),
            f0    = .data[[names(raw)[col_of(y0) + 1]]],
            v1    = parse_number(.data[[names(raw)[col_of(y1)]]], na = ":"),
            f1    = .data[[names(raw)[col_of(y1) + 1]]]) |>
  filter(geo %in% c(eu27, eu_name))

stopifnot(all(eu27 %in% wfh$geo), !anyNA(wfh$v0), !anyNA(wfh$v1))

eu    <- wfh |> filter(geo == eu_name)                     # 9.0 -> 14.2
ctry  <- wfh |> filter(geo != eu_name)
n_up  <- sum(ctry$v1 > ctry$v0)                            # 27 of 27
stopifnot(n_up == 27)                                      # the title says "all 27"

# 3. ORDER -----------------------------------------------------------------
# One list: countries and the EU, sorted by the latest year (highest at the top)
rows <- wfh |>
  mutate(is_eu = geo == eu_name,
         name  = case_when(is_eu ~ "EU-27",
                           !is.na(f1) & f1 != "" ~ paste0(geo, "*"),   # * = flag
                           TRUE ~ geo),
         name  = fct_reorder(name, v1))

# 4. COLOURS & TEXT --------------------------------------------------------
c_new <- "#1F7A80"    # teal: latest year
c_old <- "#E07A1F"    # orange: 2019
c_bar <- "#DADADA"    # line between the two years
ink   <- "#1A1A1A"; muted <- "#5A5A5A"; faint <- "#7A7A7A"; grid <- "#E6E6E6"
eu_band <- "#F2F2F2"

tt <- paste0("Since COVID, hybrid working has grown in all ", n_up, " EU countries")

st <- paste0(
  "Employed people aged 15–64 who <b>sometimes</b> work from home, % of employment, ",
  "<span style='color:", c_old, "'>**", y0, "**</span> and <span style='color:", c_new,
  "'>**", y1, "**</span>. In the EU the share rose from ", format(eu$v0, nsmall = 1),
  "% to ", format(eu$v1, nsmall = 1), "%. In the Netherlands, ",
  format(rows$v1[rows$geo == "Netherlands"], nsmall = 1), "% now work from home ",
  "some of the time; in Romania, ", format(rows$v1[rows$geo == "Romania"], nsmall = 1), "%.")

ct <- paste0("\\* Definition differs in ", y1, " (France, Spain). Break in series in 2021 ",
             "for all countries, when the Labour Force Survey changed method.<br>",
             "Data source: Eurostat, lfsa_ehomp · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
x_max <- ceiling(max(rows$v1) / 5) * 5                    # 45

p <- ggplot(rows, aes(y = name)) +
  # light band behind the EU row
  geom_tile(data = filter(rows, is_eu), aes(x = x_max / 2, width = Inf, height = 0.9),
            fill = eu_band) +
  geom_segment(aes(x = v0, xend = v1, yend = name), colour = c_bar,
               linewidth = 1.4, lineend = "round") +
  geom_point(aes(x = v0), colour = c_old, size = 2.2) +
  geom_point(aes(x = v1), colour = c_new, size = 2.6) +
  geom_text(aes(x = v0 - 1, label = format(v0, nsmall = 1),          # 2019 values, left
                fontface = if_else(is_eu, "bold", "plain")),
            hjust = 1, family = fam, size = 2.3, colour = c_old) +
  geom_text(aes(x = v1 + 1, label = format(v1, nsmall = 1),          # latest year, right
                fontface = if_else(is_eu, "bold", "plain")),
            hjust = 0, family = fam, size = 2.3, colour = c_new) +
  scale_y_discrete(limits = levels(rows$name),                  # keep the sorted order
                   labels = \(x) if_else(x == "EU-27", "**EU-27**", x)) +
  scale_x_continuous(limits = c(-3.5, x_max), breaks = seq(0, 40, 10),
                     labels = \(x) paste0(x, "%"), position = "top",
                     expand = expansion(add = c(0, 2))) +
  labs(title = tt, subtitle = st, caption = ct, x = NULL, y = NULL) +
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
    axis.text.x = element_blank(),                       # values are on the dots
    axis.text.y = element_markdown(size = 8, colour = ink, hjust = 1),
    panel.grid = element_blank(),
    panel.grid.major.x = element_line(colour = grid, linewidth = 0.3),   # light guides every 10%
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 6. SAVE ------------------------------------------------------------------
ggsave("working-from-home.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
