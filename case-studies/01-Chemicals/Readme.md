# 01 · Production of chemicals in the EU

![In 2024 the EU produced 14% fewer chemicals than in 2015](chemicals.png)

## What was published

**Eurostat news item, 21 January 2020** · [Production of chemicals](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20200121-1)

I analysed the data and wrote this item. EU production of industrial chemicals rose in 2018 compared with the previous three years but stayed below its 2004 level. It peaked in 2007, fell by about 18% during the 2008–2009 crisis, and reached 301 million tonnes in 2018 (EU-28). Between 2015 and 2017, chemicals hazardous to the environment grew fastest (+11%).

## What I explored further

The news format covered one indicator up to 2018. With the latest data (EU-27, 2015–2024) I asked what happened next:

- **2021 to 2023: −19%.** The index dropped from 100 to 81 (from 260 to 210 million tonnes), the lowest in the series, as European energy prices soared.
- **2024: partial recovery** to 86 (224 million tonnes), still well below the 2015–2021 range of about 97–107.
- **Hazard classes did not move together.** Chemicals hazardous to health fell about as much as the total and ended 2024 at 86; chemicals hazardous to the environment fell less (−16% from 2021 to 2023) and ended at 92.

## Working with the data

- **Dataset:** [`env_chmhaz`](https://ec.europa.eu/eurostat/databrowser/view/env_chmhaz/default/table), production and consumption of chemicals by hazard class, million tonnes.
- **EU-28 vs EU-27.** My 2020 item used EU-28, which included the UK, and an index with 2004 = 100. The current table covers EU-27 (2020) from 2015 only, so 2018 now reads 274 million tonnes instead of 301. The two series cannot be joined into one line, so the index now uses 2015 = 100.
- **Overlapping categories.** A chemical can be hazardous to both health and the environment, so the hazard classes overlap and do not add up to the total. The chart shows them as separate lines, not a stack.
- **Data version:** downloaded from the Eurostat data browser, last updated 12 December 2025.

## Design choices

- **An index (2015 = 100), as in the original news item.** It puts the three groups on one scale, so their trends can be compared even though their volumes differ. The 100 line is marked and the y axis is labelled "Index, 2015 = 100".
- **My own chart style, the same in every case study:** Poppins, a title that states the finding with a number, and a subtitle that explains how to read the chart. The total is dark, and the two hazard groups are orange and teal, which colour-blind readers can still tell apart.
- **Context on the chart:** the energy price crisis (2022–2023) is shaded, so readers can see when the sharpest fall happened.
- **Direct labels** at the end of each line instead of a legend; the subtitle names the colours and explains how to read an index value.

## Code

[`chemicals.R`](chemicals.R) · data in [`env_chmhaz__custom_23616204_linear.csv.gz`](env_chmhaz__custom_23616204_linear.csv.gz)
