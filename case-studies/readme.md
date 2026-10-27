# Case studies

Six of my Eurostat news items from 2020–2021, revisited with the latest data. Each folder has the write-up (`readme.md`), the R script, the data as downloaded from Eurostat, and the chart.

| # | Story | Original news item | Dataset | Question I explore |
|---|---|---|---|---|
| 01 | [Production of chemicals](01-Chemicals/) | [21 Jan 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20200121-1) | `env_chmhaz` | What happened to production after 2018? |
| 02 | [Tourism after the pandemic](02-Tourism/) | [16 Jul 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/DDN-20200716-1) | `tour_occ_nim` | How long did EU tourism take to recover, and did domestic and foreign tourists recover differently? |
| 03 | [Working from home](03-Working-from-home/) | [24 Apr 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20200424-1) | `lfsa_ehomp` | Did working from home stay after the pandemic, and where did it change most? |
| 04 | [Early school leavers](04-early-school-leavers/) | [24 Jun 2021](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20210624-2) | `edat_lfse_14` | How close is the EU to its 2030 target of below 9%, and are young men and young women equally close? |
| 05 | [Deaths from influenza](05-deaths-from-influenze/) | [7 Apr 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/DDN-20200407-1) | `hlth_cd_asdr2` | What happened to deaths from influenza during and after COVID? |
| 06 | [Digital skills](06-digital-skills/) | [14 May 2020](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/EDN-20200514-1) | `isoc_sk_dskl_i21` | How far is each EU country from the 2030 target of 80% of adults with at least basic digital skills? |

## How each write-up is structured

1. **What was published:** a short summary of the original news item
2. **What I explored further:** the latest data, longer trends and breakdowns the news format didn't allow
3. **Working with the data:** dataset codes, flags, breaks in series and other details that change the numbers
4. **Design choices:** why the chart looks the way it does
5. **Code:** the script and the data file it uses

## How to run a script

1. Download the repo.
2. Open the script in RStudio, for example `02-Tourism/tourism.R`.
3. Set the working directory to the script's folder: *Session > Set Working Directory > To Source File Location*.
4. Run the whole script. It installs any missing packages, reads the data file in the same folder and saves the chart next to the script. The first run needs internet to load the Poppins font.

<!-- ✏️ Add your R version here, e.g. "Tested with R 4.4". -->

[← Back to the main page](../README.md)
