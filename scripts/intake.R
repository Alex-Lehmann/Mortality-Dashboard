# Loads and wrangles Statistics Canada leading cause of death data

library(tidyverse)

# Load data and remove unneeded columns, pivot to wide format, fix column names
lcod = read_csv("Mortality-Dashboard/data/13100394.csv", col_types=cols()) %>%
  select(-c(GEO, DGUID, UOM, SCALAR_FACTOR, UOM_ID, SCALAR_ID, VECTOR, COORDINATE, STATUS,
            SYMBOL, TERMINATED, DECIMALS)) %>%
  rename(Year = REF_DATE, Age = `Age at time of death`,
         CauseOfDeath = `Leading causes of death (ICD-10)`, Value = VALUE) %>%
  pivot_wider(names_from=CauseOfDeath, values_from=Value) %>%
  select(-`Total, all causes of death [A00-Y89]`)
#colnames(lcod) = str_replace_all(colnames(lcod), "\\s", "_")

# Adjust age range representation
lcod$Age = lcod$Age %>%
  str_replace_all("Age at time of death, ", "") %>%
  str_replace_all("^[:lower:]", "A")

# Replace missing values with 0s; no women are dying of prostate illness, etc.
lcod = lcod %>% replace(is.na(.), 0)

# Save male, female, and combined data separately
write.csv(lcod, "Mortality-Dashboard/data/causeOfDeath.csv", row.names=FALSE)
lcod %>%
  filter(Sex == "Both sexes") %>%
  select(-Sex) %>%
  write.csv("Mortality-Dashboard/data/causeOfDeath_both.csv", row.names=FALSE)
lcod %>%
  filter(Sex == "Males") %>%
  select(-Sex) %>%
  write.csv("Mortality-Dashboard/data/causeOfDeath_males.csv", row.names=FALSE)
lcod %>%
  filter(Sex == "Females") %>%
  select(-Sex) %>%
  write.csv("Mortality-Dashboard/data/causeOfDeath_females.csv", row.names=FALSE)
