Analysis with motion outlier regressors.

Uses contingency-aware participants minus one subject with excessive number of motion outliers.
Events are copied from allsub. They model US as 1.5 seconds boxcar.
Confounds are created from fmriprep inputs and include 6 movement parameters
plus the motion_outlier columns (see prepare_data.m).

PPI analysis involves three main steps on the first level:
- "vanila" first level model, used as a basis for next steps (ppi_model.m)
- VOI eigenvariate extraction & construction of PPI term (voi_<roi name>.m)
- PPI first level model, with extracted signal as one of the columns
  (ppi_model.m, ideally placed in models_<roi name> directory)
