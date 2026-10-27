# Case study 01 · Production of chemicals in the EU
# Original Eurostat news item (21 January 2020): EU production of industrial
# chemicals rose in 2018 but stayed below its 2004 level.
# This script revisits the story with the latest data (EU-27, 2015–2024).
#
# Data: Eurostat, env_chmhaz (Production and consumption of chemicals by hazard class)
# The file in data/ was downloaded from the Eurostat data browser. To fetch it
# live instead:  eurostat::get_eurostat("env_chmhaz", type = "label")

# 1. LIBRARIES -------------------------------------------------------------
library(tidyverse)
library(showtext)
library(ggtext)

font_add_google("Poppins", family = "poppins")
showtext_auto()
showtext_opts(dpi = 288)

# 2. DATA ------------------------------------------------------------------
chem <- read_csv("../../data/env_chmhaz.csv.gz", show_col_types = FALSE) |>
  transmute(indicator = indic_env, hazard, year = TIME_PERIOD, mt = OBS_VALUE)

# 3. WRANGLING -------------------------------------------------------------
groups <- c("Hazardous and non-hazardous - total" = "All chemicals",
            "Hazardous to health"                 = "Hazardous to health",
            "Hazardous to the environment"        = "Hazardous to the environment")

prod <- chem |>
  filter(indicator == "Production of chemicals", hazard %in% names(groups)) |>
  mutate(group = factor(groups[hazard], levels = groups))

total   <- prod |> filter(group == "All chemicals")
v       <- \(y) total$mt[total$year == y]
fall    <- (v(2023) - v(2021)) / v(2021)          # the 2022–2023 drop
low     <- total |> slice_min(mt, n = 1)
envd    <- prod |> filter(group == "Hazardous to the environment")
env_fall <- (envd$mt[envd$year == 2023] - envd$mt[envd$year == 2021]) / envd$mt[envd$year == 2021]
last    <- total |> slice_max(year, n = 1)

# Labels at the end of each line
ends <- prod |> filter(year == max(year)) |>
  mutate(label = paste0("**", group, "**<br>", round(mt), " million t"))

# 4. COLOURS & TEXT --------------------------------------------------------
cols <- c("All chemicals" = "#0E3A5B", "Hazardous to health" = "#D1495B",
          "Hazardous to the environment" = "#2E8B57")
ink <- "#1A1A1A"; muted <- "#5A5A5A"; faint <- "#7A7A7A"

tt <- paste0("EU chemical production fell ", round(-fall * 100), "% during the energy crisis")

st <- paste0(
  "Production of chemicals in the EU-27, million tonnes, 2015–", last$year, ". ",
  "Output dropped from ", round(v(2021)), " million tonnes in 2021 to ", round(v(2023)),
  " million in 2023, the lowest in the series, and recovered only partly in ", last$year,
  " (", round(last$mt), " million). ",
  "Chemicals <span style='color:", cols["Hazardous to health"], "'>**hazardous to health**</span> ",
  "make up most of the total; those <span style='color:", cols["Hazardous to the environment"],
  "'>**hazardous to the environment**</span> fell less (", round(env_fall * 100), "%).")

ct <- paste0("A chemical can be hazardous to both health and the environment, so the two hazard lines ",
             "overlap and do not add up to the total. EU-27 (2020) for all years.<br>",
             "Data source: Eurostat, env_chmhaz · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
p <- ggplot(prod, aes(year, mt, colour = group)) +
  # periods to remember
  annotate("rect", xmin = 2021.5, xmax = 2023.5, ymin = -Inf, ymax = Inf,
           fill = "#F3EFE8") +
  annotate("text", x = 2022.5, y = 300, label = "Energy\nprice shock", family = "poppins",
           size = 2.5, colour = muted, lineheight = 0.95, vjust = 1) +
  annotate("segment", x = 2018, xend = 2018, y = 0, yend = 296, colour = "#C9C9C9",
           linewidth = 0.4, linetype = "22") +
  annotate("text", x = 2018.1, y = 300, hjust = 0, vjust = 1, family = "poppins", size = 2.5,
           colour = muted, lineheight = 0.95,
           label = "Last year in my\n2020 news item") +
  geom_line(linewidth = 1.2) +
  geom_point(data = filter(prod, year %in% c(2015, 2021, 2023, max(year))), size = 2.2) +
  geom_text(data = filter(total, year %in% c(2015, 2021, 2023)),
            aes(label = round(mt)), vjust = -1, family = "poppins", size = 2.6,
            colour = cols["All chemicals"], fontface = "bold", show.legend = FALSE) +
  geom_richtext(data = ends, aes(x = max(prod$year) + 0.25, label = label), hjust = 0,
                family = "poppins", size = 2.6, fill = NA, label.colour = NA,
                lineheight = 1.1, show.legend = FALSE) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = 2015:2024, labels = c("2015", paste0("’", 16:24)),
                     expand = expansion(add = c(0.3, 2.6))) +
  scale_y_continuous(limits = c(0, 305), breaks = seq(0, 300, 50), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = tt, subtitle = st, caption = ct, x = NULL, y = NULL) +
  theme_minimal(base_family = "poppins") +
  theme(
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.title = element_textbox_simple(face = "bold", size = 22, colour = ink,
                                        lineheight = 1.05, margin = margin(b = 12)),
    plot.subtitle = element_textbox_simple(size = 10.5, colour = muted,
                                           lineheight = 1.25, margin = margin(b = 18)),
    plot.caption = element_textbox_simple(size = 7, colour = faint,
                                          lineheight = 1.4, margin = margin(t = 16)),
    axis.text = element_text(size = 7.5, colour = faint),
    panel.grid = element_blank(),
    panel.grid.major.y = element_line(colour = "#ECECEC", linewidth = 0.3),
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(36, 36, 36, 36))

# 6. SAVE ------------------------------------------------------------------
ggsave("chemicals.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")
