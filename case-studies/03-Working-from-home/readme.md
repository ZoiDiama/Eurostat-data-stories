# 03 · Working from home in the EU before and after COVID

![Since COVID, hybrid working has grown in all 27 EU countries](working-from-home.png)

## What was published

**Eurostat news item, 24 April 2020** · [How usual is it to work from home?](https://ec.europa.eu/eurostat/web/products-eurostat-news/-/ddn-20200424-1)

I analysed the data and wrote this item in the first weeks of the pandemic, when social distancing was sending many people to work from home for the first time. It looked at how common home working was before COVID. In 2019, 5.4% of employed people aged 15–64 in the EU usually worked from home, a share that had barely changed in ten years, while those who sometimes did so had risen from 6.0% in 2009 to 9.0%. Self-employed people worked from home far more often than employees (19.4% against 3.2% usually did). The highest shares were in the Netherlands and Finland (14.1% each), the lowest in Bulgaria (0.5%) and Romania (0.8%).

## What I explored further

My item described the starting point. With data up to 2025, I asked whether working from home stayed after the pandemic, and in what form.

- **Hybrid working has grown in every EU country.** The share of employed people who sometimes work from home was higher in 2025 than in 2019 in all 27 countries, and rose in the EU from 9.0% to 14.2%.
- **The gaps between countries are large.** In the Netherlands 41.0% now work from home some of the time, up from 23.0%; in Romania and Bulgaria, under 3%. Some of the biggest rises were in the Netherlands (+18.0 points), Denmark (+12.4), Luxembourg (+10.2) and Cyprus (+8.8, from 1.3% to 10.1%). The smallest were in Poland (+0.3), Sweden (+0.8) and Slovenia (+0.9).
- **Full-time home working peaked and fell back; hybrid working kept growing.** The share who usually work from home more than doubled during the pandemic, then fell. It is still above 2019, but since 2022 hybrid working has again been the more common form, as it was before the pandemic:

| EU-27, % of employed people aged 15–64 | 2019 | 2020 | 2021 | 2022 | 2025 |
|---|---|---|---|---|---|
| Usually work from home | 5.4 | 12.1 | 13.3 | 10.0 | 8.8 |
| Sometimes work from home | 9.0 | 8.6 | 10.8 | 12.4 | 14.2 |

So COVID did not leave Europe working from home full-time. It left more people splitting their week between home and the workplace.

## Working with the data

- **Dataset:** [`lfsa_ehomp`](https://ec.europa.eu/eurostat/databrowser/view/lfsa_ehomp/default/table), employed persons working from home as a percentage of total employment, from the EU Labour Force Survey. Ages 15–64, both sexes, all employed persons, by frequency (usually, sometimes, never).
- **Break in series in 2021.** All countries carry the flag "b" in 2021, when the Labour Force Survey moved to a new legal framework and method. 2019 and 2025 sit on either side of this break, so part of each change may come from the method rather than from how people work. The data cannot separate the two, so the size of each change should be read with that in mind; the direction, up in every country, is the more robust finding.
- **Other flags.** In 2025 the definition differs for France and Spain ("d", marked * on the chart). In 2019 Bulgaria and Poland have a break in series ("b").
- **The same figures as in 2020.** The 2019 values in today's table match those in my news item exactly (for example 5.4% usually and 9.0% sometimes for the EU), so the comparison starts from the published baseline.
- **Data version:** downloaded from the Eurostat data browser (default view, 2016–2025), last updated 10 September 2026. The chart uses Sheet 1 ("Sometimes", total, 15–64 years).

## Design choices

- **A dumbbell chart, 2019 to 2025, one row per country.** Each line shows how far a country moved; sorting by 2025 shows where countries stand now.
- **Colours stand for years:** orange for 2019, teal for 2025, named in the subtitle instead of a legend.
- **The EU row in bold on a light band,** in its sorted place, so countries above it are above the EU average and countries below it are below.
- **Values at both ends of each line, and no axis labels.** Every value is written on the chart, so axis labels only added clutter; light gridlines every 10 points stay as a visual guide.
- **Simpler than my first draft.** I first tried a mirrored layout with countries above and below the EU average on opposite sides of the chart. It looked striking but added nothing a sorted list with an EU row doesn't show more clearly.
- **My own chart style, the same in every case study:** Poppins, a title that states the finding, and a subtitle with the key numbers.

## Code

[`working-from-home.R`](working-from-home.R) · data in [`data/lfsa_ehomp.xlsx`](../../data/lfsa_ehomp.xlsx), Sheet 1
