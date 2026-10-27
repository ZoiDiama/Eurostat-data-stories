# Working with Eurostat data

Things I learned writing news items from Eurostat tables, and how I handle them in R.

Overall, Eurostat data are easy to work with. The datasets are well organised, the data are clean and consistent across countries, and every dataset comes with its methodology. Most Eurostat stories compare countries with each other and over time, and that is where most of the care is needed. Before writing a sentence, I check what exactly the indicator measures, whether the values carry flags, and whether the method has changed over the years. The sections below are the points I check most often, each with an example from my case studies.

## 1. Getting the data

Every Eurostat table has a code, for example `env_chmhaz`. You can download it from the [data browser](https://ec.europa.eu/eurostat/databrowser/) or fetch it in R:

```r
library(eurostat)
chem <- get_eurostat("env_chmhaz", type = "label")
```

A spreadsheet download from the data browser has one sheet for each combination of filters (sex, age, unit and so on), so a single file can have more than a hundred sheets. In my scripts I check each sheet's labels before using it, so the chart cannot be built from the wrong one. I also note the "last updated" date of every download, because the figures can change later (see [Revisions](#7-revisions)).

Before using a table, I check five things:

1. **What it measures.** The full title and the metadata page: the definition of the indicator, who is covered (for example people aged 18–24) and how the data are collected.
2. **The unit.** Percentage, rate per 100,000, index or absolute number, and percentage of what (all people, or only internet users?).
3. **The filters.** Every table has dimensions such as sex, age, unit or cause. The default view is not always the one the story needs, so I set each filter on purpose.
4. **Coverage.** Which countries and years have data, and whether the EU aggregate is there for every year.
5. **The latest published figures.** I compare my numbers with what Eurostat itself has published on the topic. If they match, I know I have the right table and the right filters.

**Example:** for [case study 05](case-studies/05-deaths-from-influenze/), my first download of `hlth_cd_asdr2` kept the default causes of death, which did not include influenza. Checking the filters before the analysis caught it.

## 2. EU aggregates change over time

| Aggregate | Countries | Watch out |
|---|---|---|
| EU-28 | 2013 – January 2020, including the UK | Used in articles published before February 2020 |
| EU-27 (2020) | From February 2020, without the UK | Old and new series cannot be joined into one line |

**Example:** in my 2020 chemicals item, 2018 production was 301 million tonnes (EU-28). The same year now reads 274 million tonnes (EU-27). [See case study 01](case-studies/01-Chemicals/).

## 3. Flags

Flags are short codes next to a value that tell you something about it. Not every flag means a problem: some describe how the value was produced, others warn that it is less reliable or not fully comparable. The ones I met most often:

| Flag | Meaning | What I do |
|---|---|---|
| `p` | Provisional | Use it, and say the figure may change |
| `e` | Estimated | Use it, and say it is an estimate |
| `b` | Break in time series | Compare across the break with caution (see section 4) |
| `u` | Low reliability | Show it, mark it, and do not build a finding on it alone |
| `d` | Definition differs | Mark it; the country is not fully comparable with the others |
| `c` | Confidential | No value is published |
| `:` | Not available | Leave the country out and say so |

**Example:** in [case study 04](case-studies/04-early-school-leavers/), the 2025 values for Croatia are flagged `u` and those for Spain and France `d`. I marked them on the chart (†, \*) and explained them in the caption. Luxembourg had no published value, so the chart shows 26 countries, not 27.

## 4. Breaks in series

A break in series means that the way the data are collected or defined changed in a given year: a new survey method, a new definition or a new classification. The series continues, but values before and after the break are not fully comparable, so changes across the break should be read with caution. Sometimes the change is so large that Eurostat starts a new indicator instead.

**Examples:**
- In 2021 the EU Labour Force Survey moved to a new legal framework and method, and every country has a `b` flag that year. In [case study 03](case-studies/03-Working-from-home/), 2019 and 2025 sit on either side of the break, so I treat the direction of the change (up in all 27 countries) as more robust than its exact size.
- Digital skills have been measured with a new indicator since 2021. The figures in my 2020 news item cannot be put on the same line as today's ([case study 06](case-studies/06-digital-skills/)).

## 5. Standardised rates

A crude death rate divides the number of deaths by the whole population. Countries with older populations have more deaths simply because more of their people are old, so crude rates are not a fair comparison. An age-standardised rate removes this effect: it shows how many deaths a country would have if its population had the same age structure as a common standard population (the European Standard Population). Standardised rates are the right choice for comparing countries or years. Crude rates and numbers of deaths are better for describing the real burden in one country.

**Example:** flu deaths are concentrated among older people. In [case study 05](case-studies/05-deaths-from-influenze/) I used age-standardised rates (0.93 deaths per 100,000 inhabitants in the EU in 2016) so that differences between countries do not just reflect how old their populations are. Standardisation does not remove every difference, though: countries also record causes of death differently.

## 6. Categories that do not add up

The parts of a breakdown do not always add up to the total. The usual reasons are:

- **Overlapping categories.** In `env_chmhaz`, a chemical can be hazardous to both health and the environment, so it is counted in both hazard classes ([case study 01](case-studies/01-Chemicals/)).
- **Overlapping groups in the same table.** The digital skills table has age groups 16–19, 16–24 and 16–29 side by side. Only groups that do not overlap can be compared or added ([case study 06](case-studies/06-digital-skills/)).
- **Combined levels.** "Basic or above basic" is the sum of "basic" and "above basic", so the three cannot be added together.
- **Hidden or missing parts.** Totals can include "unknown" or "not stated" answers, or confidential values that are not shown separately.
- **Rounding.** Rounded parts can add up to slightly more or less than the rounded total.

Before adding categories, I check the dataset's metadata to see whether they are exclusive.

## 7. Revisions

Published figures are revised as countries send new or corrected data. A value I wrote in 2020 or 2021 can be different in today's table.

**Example:** in my 2021 news item on early school leavers, Malta's 2020 rate was 16.7%; today it is 13.0%. The EU rate moved from 9.9% to 10.0% ([case study 04](case-studies/04-early-school-leavers/)). This is why every case study states the date its data were downloaded.

## 8. Units and definitions

The same number can look very different depending on the unit. My 2020 influenza item gave 9 deaths per million inhabitants; the dataset gives 0.93 per 100,000. It is the same figure, so I always state the unit. In the same way, I read the exact definition of the indicator before I describe it. For example, an "early leaver" is someone aged 18–24 with at most lower secondary education who is not in further education or training. It does not mean someone who left school early in general.

## 9. Writing for the public

Statistics for the public should be simple and clear, written for readers who are not statisticians. Short sentences, one main message, and numbers that are rounded and given with their unit.

Above all, the text should say what the data show, not why. A table can show that a figure went up or that two groups differ, but it cannot show the reason. Explaining a change or claiming a cause needs more data and further analysis than a single dataset can give. That is why short statistical news is mostly descriptive, and why speculation does not belong in it.

When a pattern suggests an explanation, I say what the data can and cannot tell us. **Example:** in [case study 05](case-studies/05-deaths-from-influenze/), flu deaths almost disappeared in 2021, when COVID measures were in place. The write-up points out the timing but says that the data show the drop, not its cause. In [case study 06](case-studies/06-digital-skills/), people living with children have better digital skills, but they are also younger on average, so the gap cannot be read as an effect of having children.
