# Working with Eurostat data

Things I learned writing news items from Eurostat tables, and how I handle them in R.

<!-- ✏️ This page should be in your own voice: it is the evidence of your experience.
     Each section has prompts. Keep each one short (3–6 sentences) and add one real example. -->

## 1. Getting the data

Every Eurostat table has a code, for example `env_chmhaz`. You can download it from the [data browser](https://ec.europa.eu/eurostat/databrowser/) or fetch it in R:

```r
library(eurostat)
chem <- get_eurostat("env_chmhaz", type = "label")
```

<!-- ✏️ How did you find the right table for an article? What did you check first? -->

## 2. EU aggregates change over time

| Aggregate | Countries | Watch out |
|---|---|---|
| EU-28 | 2013 – January 2020, including the UK | Used in articles published before February 2020 |
| EU-27 (2020) | From February 2020, without the UK | Old and new series cannot be joined into one line |

**Example:** in my 2020 chemicals item, 2018 production was 301 million tonnes (EU-28). The same year now reads 274 million tonnes (EU-27). [See case study 01](case-studies/01-chemicals/).

## 3. Flags

<!-- ✏️ Which flags did you meet most often (p provisional, e estimated, b break in series,
     c confidential, : not available)? How did you mention them in an article? -->

## 4. Breaks in series

<!-- ✏️ An example where a method change affected a comparison over time. -->

## 5. Standardised rates

<!-- ✏️ Why death rates are age-standardised before comparing countries (e.g. your influenza item). -->

## 6. Categories that do not add up

Some breakdowns overlap. In `env_chmhaz`, a chemical can be hazardous to both health and the environment, so the hazard classes do not add up to the total.

<!-- ✏️ Any other examples: age groups, "total" vs sum of countries, etc. -->

## 7. Writing for the public

<!-- ✏️ The house rules you followed: neutral wording, no causal claims, rounding, how you chose the headline. -->
