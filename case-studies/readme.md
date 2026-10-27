# Case studies

Each case study goes back to one of my Eurostat news items, updates it with the latest data and takes the analysis further than the news format allowed. Each one also shows a different part of working with Eurostat data.

| # | Case study | Original news item | Dataset | Working with the data |
|---|---|---|---|---|
| 01 | [Production of chemicals in the EU](01-chemicals/) | [21 Jan 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20200121-1) | `env_chmhaz` | EU-28 vs EU-27, overlapping categories |
| 02 | [Tourism nights in the EU after the pandemic](02-tourism/) | [16 Jul 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/DDN-20200716-1) | `tour_occ_nim` | Monthly data, seasonality, published comparisons |
| 03 | Working from home *· coming soon* | [24 Apr 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/DDN-20200424-1) | | Breaks in series |
| 04 | Early school leavers *· coming soon* | [24 Jun 2021](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20210624-2) | | Flags, EU targets |
| 05 | Regional map: deaths from prostate cancer *· coming soon* | [19 Nov 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/EDN-20201119-1) | | Standardised death rates, NUTS regions |
| 06 | ICT specialists *· coming soon* | [16 Jul 2021](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20210716-1) | | Definitions, EU targets |

## How each case study is organised

Every folder has the same three files:

| File | What's inside |
|---|---|
| `README.md` | The write-up: what was published, what I explored further, working with the data, design choices |
| `<name>.R` | The R script that reads the data and makes the chart |
| `<name>.png` | The chart |

The data files are in the [`data/`](../data/) folder at the top of the repo, as downloaded from the Eurostat data browser.

## Running the code

1. Open the case study's `.R` file in RStudio.
2. Choose **Session → Set Working Directory → To Source File Location**.
3. Run the whole script. It installs any missing packages and saves the chart as a `.png` in the same folder.

The first run needs an internet connection to load the Poppins font.
