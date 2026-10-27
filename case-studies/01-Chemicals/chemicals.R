# Case study 01 · Production of chemicals in the EU
# Original Eurostat news item (21 January 2020): EU production of industrial
# chemicals rose in 2018 but stayed below its 2004 level (EU-28, index 2004 = 100).
# This script revisits the story with the latest data (EU-27, 2015–2024),
# keeping the index format of the original, now with 2015 = 100.
#
# Data: Eurostat, env_chmhaz (Production and consumption of chemicals by hazard class)
# Downloaded from the Eurostat data browser. To fetch it live instead:
#   eurostat::get_eurostat("env_chmhaz", type = "label")

# 0. SETUP -----------------------------------------------------------------
# Run this script from its own folder (case-studies/01-chemicals/).
# In RStudio: Session > Set Working Directory > To Source File Location.
# If your file has a different name, change it here.
file_chem <- "../../data/env_chmhaz.csv.gz"

if (!file.exists(file_chem)) stop("File not found: ", file_chem, "\nWorking directory is: ",
                                  getwd(), "\nSet the working directory to this script's ",
                                  "folder, or change the file name in section 0.")

# 1. LIBRARIES -------------------------------------------------------------
pkgs <- c("tidyverse", "showtext", "ggtext")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

library(tidyverse)
library(showtext)
library(ggtext)

font_add_google("Poppins", "poppins")   # needs internet the first time
showtext_auto()
showtext_opts(dpi = 288)
fam <- "poppins"

# 2. DATA ------------------------------------------------------------------
chem <- read_csv(file_chem, show_col_types = FALSE) |>
  transmute(indicator = indic_env, hazard, year = TIME_PERIOD, mt = OBS_VALUE)

# 3. WRANGLING -------------------------------------------------------------
groups <- c("Hazardous and non-hazardous - total" = "All chemicals",
            "Hazardous to health"                 = "Hazardous to health",
            "Hazardous to the environment"        = "Hazardous to the environment")

base_year <- 2015

prod <- chem |>
  filter(indicator == "Production of chemicals", hazard %in% names(groups)) |>
  mutate(group = factor(groups[hazard], levels = groups)) |>
  group_by(group) |>
  mutate(index = mt / mt[year == base_year] * 100) |>     # 2015 = 100
  ungroup()

idx  <- \(g, y) prod$index[prod$group == g & prod$year == y]
last <- max(prod$year)

tot_last <- idx("All chemicals", last)                  # 86
env_last <- idx("Hazardous to the environment", last)   # 92
hea_last <- idx("Hazardous to health", last)            # 86
tot_peak <- prod |> filter(group == "All chemicals") |> slice_max(index, n = 1)
tot_low  <- prod |> filter(group == "All chemicals") |> slice_min(index, n = 1)

# Labels at the end of each line. Poppins is wider than Arial, so the long
# label is split over two lines. All chemicals and health end at the same
# value, so they are pushed apart.
end_names <- c("All chemicals"                = "All chemicals",
               "Hazardous to health"          = "Hazardous to health",
               "Hazardous to the environment" = "Hazardous to<br>the environment")
ends <- prod |> filter(year == last) |>
  mutate(label = paste0("**", end_names[as.character(group)], "**<br>", round(index)),
         y = index + c(2.6, -2.8, 0.5)[as.integer(group)])

# 4. COLOURS & TEXT --------------------------------------------------------
# Text colours: my chart style. Line colours: dark for the total, then orange
# and teal, which stay distinct for colour-blind readers (no red with green).
cols <- c("All chemicals"                = "#1A1A1A",
          "Hazardous to health"          = "#E07A1F",
          "Hazardous to the environment" = "#1F7A80")
ink   <- "#1A1A1A"   # title
muted <- "#5A5A5A"   # subtitle, annotations
faint <- "#7A7A7A"   # caption, axis text
grid  <- "#E6E6E6"
shade <- "#F2F2F2"

tt <- paste0("In ", last, " the EU produced ", round(100 - tot_last),
             "% fewer chemicals than in ", base_year)

st <- paste0(
  "Production of chemicals in the EU, index ", base_year, " = 100. ",
  "A value of ", round(tot_last), " means production was ", round(100 - tot_last),
  "% below the ", base_year, " level. ",
  "Production peaked in ", tot_peak$year, " and fell to its lowest in ", tot_low$year,
  " (", round(tot_low$index), "), during the energy price crisis. ",
  "Chemicals <span style='color:", cols["Hazardous to the environment"],
  "'>**hazardous to the environment**</span> fell least (", round(env_last),
  "), while those <span style='color:", cols["Hazardous to health"],
  "'>**hazardous to health**</span> fell as much as the total.")

ct <- paste0("EU-27 (2020). A chemical can be hazardous to both health and the environment, ",
             "so the hazard groups overlap.<br>",
             "Data source: Eurostat, env_chmhaz · Creator: Zoi Diamantakou")

# 5. PLOT ------------------------------------------------------------------
p <- ggplot(prod, aes(year, index, colour = group)) +
  annotate("rect", xmin = 2021.5, xmax = 2023.5, ymin = -Inf, ymax = Inf, fill = shade) +
  annotate("text", x = 2022.5, y = 110.5, label = "Energy\nprice crisis", family = fam,
           size = 2.5, colour = muted, lineheight = 0.95, vjust = 1) +
  geom_hline(yintercept = 100, colour = faint, linewidth = 0.4) +
  annotate("text", x = last + 0.25, y = 100, label = paste0(base_year, " = 100"), hjust = 0,
           vjust = -0.5, family = fam, size = 2.4, colour = faint) +
  geom_line(linewidth = 1.2) +
  geom_point(data = filter(prod, year == last), size = 2.2) +
  geom_richtext(data = ends, aes(x = last + 0.25, y = y, label = label), hjust = 0,
                family = fam, size = 2.6, fill = NA, label.colour = NA,
                lineheight = 1.1, show.legend = FALSE) +
  scale_colour_manual(values = cols, guide = "none") +
  scale_x_continuous(breaks = 2015:2024, expand = expansion(add = c(0.3, 2.8))) +
  scale_y_continuous(limits = c(76, 111), breaks = seq(80, 110, 10), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = tt, subtitle = st, caption = ct, x = NULL,
       y = paste0("Index, ", base_year, " = 100")) +
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
ggsave("chemicals.png", p, width = 7.5, height = 7.5, dpi = 288, bg = "white")