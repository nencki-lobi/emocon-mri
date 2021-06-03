# STATS

Files for producing statistics and figures reporeted in the article. Uses R markdown files, JASP files or Python scripts.

## Contents

- contingency_table.Rmd: stats on contingency knowledge
- evaluation\_of\_demonstrator.Rmd: analysis of evaluation of demonstrator, comparing friend and stranger groups
- questionnaire_analysis.Rmd: analysis of STAI and SWE, comparing friend and stranger group
- roi_bayes.Rmd: region-of-interest between-group analysis
- skin_conductance.Rmd: analysis of skin conductance response amplitudes produced by PsPM
- skin_conductance.jasp: JASP file with bayesian ANOVA for skin conductance
- state\_anxiety\_ctg.jasp: JASP file with bayesian ANOVA for STAI-state

## Comments

The Rmd documents can be exported to html either from an IDE / editor of choice (Rstudio, emacs with ess) or by running:

```
Rscript -e "rmarkdown::render('<filename>.Rmd', output_format = 'html_document', output_file = '<filename>-exported.html')"
```
