# Communicating European statistics

**Case studies from my two years writing for Eurostat, revisited with today's data and my own visuals in R.**

## About the project

From 2020 to 2021 I worked as a statistical consultant for a company contracted by Eurostat to produce its ["What's New"](https://ec.europa.eu/eurostat/en/news/news-articles) news items. For each item Eurostat set the topic and the dataset. I analysed the data, checked the figures, shaped the angle where there was room to, and wrote the text to Eurostat's short news format: **125 articles** across all of Eurostat's statistical themes, every one delivered on time.

I was also the link between Eurostat, our partner and our design subcontractor. I set the deadlines, made clear what each article needed, briefed the graphic designer on the visuals, and handled the review rounds until each item was ready to publish.

Many of those stories were written with data that stopped in 2018 or 2019, or in the middle of the pandemic. Today the data show what happened next. Here I return to some of them: I update them with the latest data, take the analysis further than the short news format allowed, and this time make the charts myself, in R.

## Case studies

<table>
<tr>
<td width="33%" valign="top"><a href="case-studies/01-chemicals/"><img src="case-studies/01-chemicals/chemicals.png" width="100%" alt="Chemicals production chart"></a><br><b><a href="case-studies/01-chemicals/">EU chemical production fell 19% during the energy crisis</a></b><br><sub>Environment and energy · <code>env_chmhaz</code></sub></td>
<td width="33%" valign="top"><i>Coming soon</i></td>
<td width="33%" valign="top"><i>Coming soon</i></td>
</tr>
</table>

## What this repo shows

- **Analysis and writing:** turning official tables into short, accurate news stories, and taking them further.
- **Eurostat data:** dataset codes, EU aggregates, breaks in series, flags. See [Working with Eurostat data](working-with-eurostat.md).
- **Data visualisation in R:** ggplot2, one consistent design, reproducible code.

## Repo layout

| Folder | What's inside |
|---|---|
| [`case-studies/`](case-studies/) | One folder per story: write-up, R script and chart |
| [`publications.md`](publications.md) | All my published articles |
| [`working-with-eurostat.md`](working-with-eurostat.md) | Working with Eurostat data |

## Credits

All data © European Union, Eurostat, reused under the [Eurostat copyright policy](https://ec.europa.eu/eurostat/about-us/policies/copyright). The analysis and charts in this repo are my own and are not official Eurostat products.

Made by [Zoi Diamantakou](https://github.com/ZoiDiama)
