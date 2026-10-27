# Case studies

Six of my Eurostat news items from 2020–2021, revisited with the latest data. Each folder has the write-up (`README.md`), the R script and the chart.

| # | Story | Original news item | Dataset | Question I explore | Status |
|---|---|---|---|---|---|
| 01 | [Production of chemicals](https://github.com/ZoiDiama/Eurostat-data-stories/tree/main/case-studies/01-Chemicals) | 21 Jan 2020 | `env_chmhaz` | What happened to production after 2018? | ✅ Done |
| 02 | [Tourism after the pandemic](case-studies/02-Tourism) | 16 Jul 2020 | `tour_occ_nim` | How long did EU tourism take to recover, and did domestic and foreign tourists recover differently? | ✅ Done |
| 03 | Working from home | 24 Apr 2020 | `lfsa_ehomp` <!-- ✏️ confirm code --> | Did working from home stay after the pandemic, and where did it change most? | Coming soon |
| 04 | Early school leavers | 24 Jun 2021 | `edat_lfse_14` <!-- ✏️ confirm code --> | Has the EU reached its 2030 target of under 9%, and which countries are far from it? | Coming soon |
| 05 | Prostate cancer deaths in EU regions | 19 Nov 2020 | `hlth_cd_asdr2` <!-- ✏️ confirm code --> | Where are men most likely to die from prostate cancer, once we account for age? | Coming soon |
| 06 | ICT specialists | 16 Jul 2021 | `isoc_sks_itspt` <!-- ✏️ confirm code --> | Is the EU on track for 20 million ICT specialists by 2030, and how large is the gender gap? | Coming soon |

## How each write-up is structured

1. **What was published:** a short summary of the original news item
2. **What I explored further:** the latest data, longer trends and breakdowns the news format didn't allow
3. **Working with the data:** dataset codes, flags, breaks in series and other details that change the numbers
4. **Design choices:** why the chart looks the way it does
5. **Code:** how to run the script

## How to run a script

1. Download the repo.
2. Open the script in RStudio, for example `02-tourism/tourism.R`.
3. Install the packages listed at the top of the script.
4. Run it. It reads the data from the `data/` folder and saves the chart next to the script.

<!-- ✏️ Add your R version here, e.g. "Tested with R 4.4". -->

[← Back to the main page](../README.md)
