# Gather files exported by PsPM into a tidy dataframe
# separate file for OFL, different logic

library(tidyverse)
library(ini)

config <- read.ini('../config.ini')

# Load participant group / contingency info & join into the wide dataframe
participants <- read_csv(file.path(config$PSPM$ROOT, 'participants.csv')) %>%
  rename(subject = label) %>%
  mutate(subject = str_c("sub-", subject))

# read exported file names
files <- list.files(
  path = file.path(config$PSPM$ROOT, 'stats_scr_dcm'),
  pattern = 'task-ofl.tsv',
  full.names = TRUE,
)

# process subjects in a loop and collect tidy dataframes
frames = vector("list", length(files))
for (n in 1:length(files)) {

  f <- files[n]
  sub_name <- str_extract(basename(f), "sub-[A-Za-z]+")
  sub_info <- participants %>% filter(subject==sub_name)

  df <- read_tsv(f, skip=1, col_types = cols()) %>%
    rename_with(paste, !matches("[0-9]$"), '0', sep="_") %>%
    mutate(
      X193 = NULL,
      subject=sub_name,
      group=sub_info$group,
      contingency=sub_info$contingency)

  frames[[n]] <- df %>%
    pivot_longer(
      starts_with("CS"),
      names_to = c("stimulus", "trialinfo", "measure", "trial"),
      names_pattern = "(.*) - (.*): (.*)_(\\d+)",
      names_transform = list(trial=as.integer)) %>%
    mutate(
      trial = trial + 1,
      measure = str_replace(measure, 'response amplitude', 'amplitude')) %>%
    spread(measure, value)

}

tidy_df <- bind_rows(frames)
write_tsv(tidy_df, file.path(config$PSPM$ROOT, 'all_ofl.tsv'))
