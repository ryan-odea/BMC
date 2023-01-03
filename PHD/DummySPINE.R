if(!require(pacman)) install.packages(pacman)
pacman::p_load(tidyverse,
               data.table)

`%ni%` <- Negate(`%in%`)

raw.intake <- function(directory){
  id_check <- c()
  
  intake <- lapply(list.files(path = directory,
                              full.names = TRUE),
                   haven::read_sas) %>% 
    lapply(., rename_with, toupper) %>%
    lapply(., rename, any_of(c(ID = "PHDID")))
  
  for (i in 1:length(intake)) {
    if("ID" %ni% colnames(intake[[i]])){
      id_check <- append(id_check, i) 
    }
  }
  
  intake <- intake[-id_check]
}
raw.merge <- function(df, filter){
  df %>% select(contains(paste(filter))) %>% 
    unite(., merge, paste(colnames(.))) %>% 
    as.data.frame() %>% 
    mutate(merge = gsub("9", "",
                        gsub("NA", "",
                             gsub("_", "", merge))))
}
raw.clean <- function(df_list){
  data <- purrr::reduce(df_list, left_join, by = "ID") %>%
    select(ID, contains(c("RACE", "SEX")),
           -contains(c("FATHER", "MOTHER"))) %>% 
    group_by(ID) %>% 
    fill(.) %>%
    slice(1) %>% 
    ungroup()
  
  race_unite <- raw.merge(data, "RACE") %>% 
    apply(., 1, function(x) names(which.max(table(strsplit(x, ""))))) %>% 
    data.frame("RACE_FINAL" = .)
  
  sex_unite <- raw.merge(data, "SEX") %>% 
    apply(., 1, function(x) names(which.max(table(strsplit(x, ""))))) %>% 
    data.frame("SEX_FINAL" = .)
  
  main_merge <- cbind(data$ID, race_unite, sex_unite)
  
  return(main_merge)
}

SPINE <- raw.clean(raw.intake("DummyData/"))
write.csv(SPINE, "dummySpine.csv")
