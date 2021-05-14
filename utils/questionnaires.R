### Script for converting the original ("working version") xlsx table
### with questionnaire data into a curated text file for use and
### publication. Mostly translation, renaming and data type
### corrections.
### Relies on demonstrators.py (matching demonstrators to
### strangers-observers based on log files) being executed first.
###
### Done using R version 4.0.5 ("Shake and Throw") & tidyverse 1.3.0

library(tidyverse)
library(readxl)
library(ini)

## specify paths

config <- read.ini("../config.ini")

source_file <- file.path(
    config$DEFAULT$QUESTIONNAIRE_DIR, "ANKIETY_fmri2019_odwrócone.xlsx")
participants_file <- file.path(
    config$DEFAULT$BIDS_ROOT, "participants.tsv")
demonstrators_file <- file.path(
    config$DEFAULT$QUESTIONNAIRE_DIR, "demonstrators.tsv")
output_file <- file.path(
    config$DEFAULT$QUESTIONNAIRE_DIR, "table.tsv")

## load the big table, drop id column

df <- read_excel(source_file, na = c("", 'NA', 'na', '-')) %>%
    select(! Numer)

# remove pilot data, which used the same demonstrator
# and remove subjects with technical issues (stranger group):
#    TRLTDN - massive video playback issues
#    CGOTOP - video shown mirrored (later replaced by ORTKLP)
#    PLARRE - video shown mirrored (not replaced in the end)

df <- df %>%
    filter(is.na(`Wersja stranger`) | `Wersja stranger` != "aktor") %>% 
    filter(! Kod %in% c("TRLTDN1", "CGOTOP1", "PLARRE1")) %>% 
    select(! `Wersja stranger`)

## translate column names & make them easier to handle

df <- df %>% rename(
    subject_id = Kod,
    role = Rola,
    group = Grupa,
    cs_version = 'Wersja (1-niebieski, 2-żółty)',
    scan_date = Data,
    age = wiek,
    MFQ_ra = wynik_przyjazn,
    friendship_length = staz_znajomosci,
    contact_frequency = czestosc_kontaktu,
    ED_discomfort = dyskomfort,
    ED_expressive = 'siła_reakcji',
    ED_natural = 'naturalność_reakcji',
    ED_empathy = odczuwana_empatia,
    ED_identify = identyfikacja,
    CONT_could_predict_shock = 'czy_potrafiłeś_przewidzieć_szok',
    CONT_how = 'jak?',
    CONT_pct_blue = '%_niebieskich',
    CONT_pct_yellow = '%_żółtych',
    CONT_pct_fix = "%_fix",
    CONT_color_choice_correct = poprawne_wskazanie_koloru,
    CONT_at_what_stage = 'od_jakiego_momentu',
    CONT_what_was_first = 'co_było_najpierw',
    CONT_shock_pleasant = 'czy_szok_był_przyjemny',
    CONT_contingency = CONTINGENCY,
    SWE_empathic_concern = empatyczna_troska,
    SWE_personal_distress = osobista_przykrosc,
    SWE_perspective_taking = przyjmowanie_perspetktywy
    )

## translate repeating words in column names: state, trait, total, q(uestion)
## use state1 & state2 instead of state_1 & state_2 consistently

df <- df %>% 
    rename_with(
        .fn = ~ gsub('stan', 'state', .x),
        .cols = starts_with('STAI')) %>%
    rename_with(
        .fn = ~ gsub('cecha', 'trait', .x),
        .cols = starts_with('STAI')) %>%
    rename_with(
        .fn = ~ gsub('WYNIK', 'total', .x),
        .cols = starts_with('STAI')) %>%
    rename_with(
        .fn = ~gsub("state_([12])", "state\\1", .x),
        .cols = starts_with('STAI')) %>%
    rename_with(
        .fn = ~ gsub('pyt', 'q', .x),
        .cols = starts_with(c('STAI', 'SWE')))

## capitalise subject ids & create label column (letters only)

df <- df %>%
    mutate(
        subject_id = str_to_title(subject_id),
        label = str_sub(subject_id, 1, -2)) %>%
    relocate(label, .after=subject_id)

## use simple dates, not POSIXct

df <- mutate(df, scan_date = as.Date(scan_date))

## translate categorical responses
df <- df %>% mutate(
    contact_frequency = recode(
        contact_frequency,
        'raz w miesiącu' = 'once a month',
        'kilka razy w miesiącu' = 'couple times a month',
        'kilka razy w tygodniu' = 'couple times a week',
        ),
    CONT_could_predict_shock = recode(
        CONT_could_predict_shock,
        'TAK' = 'YES',
        'NIE' = 'NO',
        ),
    CONT_what_was_first = recode(
        CONT_what_was_first,
        'STYMULACJA' = 'shock',
        'OBRAZEK' = 'symbol',
        ),
    CONT_contingency = recode(
        CONT_contingency,
        'TAK' = 'YES',
        'NIE' = 'NO',
        ),
    CONT_color_choice_correct = recode(
        CONT_color_choice_correct,
        'TAK' = 'YES',
        'NIE' = 'NO',
        ),
    )

## correct percentage ranges which were entered differently
df <- df %>%
    mutate(
        CONT_pct_blue = recode(
            CONT_pct_blue, '80' = '71-80', '15' = '11-20'),
        CONT_pct_yellow = recode(
            CONT_pct_yellow, '10' = '1-10', '20' = '11-20'),
        CONT_pct_fix = recode(
            CONT_pct_fix, '10' = '1-10'),
        )

## load subject & age from BIDS participants file
## load file with demonstrator-observer pairs (prepared with a .py script)

participants <- read_tsv(participants_file, col_types = cols()) %>%
    mutate(
        label = str_sub(participant_id, 5, -1),  # drop "sub-"
        role = "OBS") %>%                        # participants are observers
    select(c("label", "role", "age"))

demonstrators <- read_tsv(demonstrators_file, col_types = cols())

## append age from BIDS
df <- left_join(df, participants,
                by = c("label", "role"),
                suffix=c("_q", "_dicom")) %>%
    relocate(age_dicom, .after=age_q)

## keep one age column, with dicom values as the prevalent ones
## for observers is more accurate (MR console, at the day of scan)
df <- df %>%
    mutate(
        age = if_else(is.na(age_dicom), age_q, age_dicom),
        age_q = NULL,
        age_dicom = NULL
    ) %>%
    relocate(age, .after = group)

## append demonstrator (label) column from demonstrators file
df <- left_join(df, demonstrators, by = c("label" = "observer"))

## insert demonstrator label also for the friend group (i. e. copy label)
df <- df %>%
    mutate(
        demonstrator = if_else(
            group == 'friend' & role == "OBS",
            label,
            demonstrator
        )
    )

## get the ids of the demonstrators in friend version
dems_live <- df %>%
    filter(group=="friend" & role == "DEM") %>%
    select(c("subject_id", "label")) %>%
    rename(demonstrator_id = subject_id)

## replace demonstrator labels by their ids
df <- df %>%
    left_join(dems_live, by=c("demonstrator" = "label")) %>%
    relocate('demonstrator_id', .after = age) %>%
    select(-demonstrator)

## delete scan date
df <- df %>%
    select(-scan_date)

## delete individual items from STAI & SWE
df <- df %>%
    select(! (matches("STAI_.*_q[0-9]+") | matches("SWE_q[0-9]+")) )

write_tsv(df, output_file)
