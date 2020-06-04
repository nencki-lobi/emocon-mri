# Gather files exported by PsPM into a tidy dataframe

library(tidyverse)
library(ini)

load_subject <- function(f) {

  label = str_extract(basename(f), "sub-[A-Za-z]+")

  tab = read_tsv(f, skip=1) %>%
    rename_with(paste, !matches("[0-9]$"), '0', sep="_") # numbers will autogenerate, add _0 to 1st

  # specify column order - for stacking (but redundant if we want long form...)
  reordered <- bind_cols(
    subject=label,
    select(tab, starts_with("CS plus")),
    select(tab, starts_with("CS minus")),
  )

  return(reordered)
}

config <- read.ini('/Users/michal/Documents/emocon_mri_study/config.ini')

# read exported files (wide-format) and put them together
files <- list.files(
  path = file.path(config$PSPM$ROOT, 'stats_scr_dcm'),
  pattern = 'task-de.tsv',
  full.names = TRUE,
)

sub_frames <- lapply(files, load_subject)
wide_df <- bind_rows(sub_frames)

# Load participant group / contingency info & join into the wide dataframe
participants <- read_csv(file.path(config$PSPM$ROOT, 'participants.csv')) %>%
  rename(subject = label) %>%
  mutate(subject = str_c("sub-", subject))
  
wide_df <- wide_df %>%
    left_join(participants) %>%
    relocate(group, contingency, .after=subject)

# Convert to tidy by:
# - pivoting to long form, putting trial info from header into several columns
# - spreading to get amplitude, dispersion & peak latency as columns

tidy_df <- wide_df %>%
  pivot_longer(
    starts_with("CS"),
    names_to = c("stimulus", "trialinfo", "measure", "trial"),
    names_pattern = "(.*) - (.*): (.*)_(\\d+)",
    names_transform = list(trial=as.integer)
  ) %>%
  spread(measure, value)

# count trials from 1
tidy_df$trial <- tidy_df$trial + 1

write_tsv(tidy_df, file.path(config$PSPM$ROOT, 'all_de.tsv'))
