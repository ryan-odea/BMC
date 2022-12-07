if(!require(pacman)) install.packages(pacman)
pacman::p_load(tidyverse,
               data.table)

###HUC PRIORS INTAKE####
intake <- lapply(list.files(path = "huc_priors/", 
                            full.names = TRUE),
                 fread) %>% 
  rbindlist(., idcol = "File", fill = TRUE) %>% 
  mutate(File = factor(File, 
                       labels = c(list.files(path = "huc_priors/"))))

###HTCINTAKE####
comparison <- fread("healthcare utilization CTN.csv") %>% 
  janitor::clean_names() %>%
  mutate(block = recode(block,
                         "No_Treatment" = "no_trt",
                         "Buprenorphine" = "bup",
                         "Buprenorphine" = "sublocade"),
         oud = recode(oud,
                      "Active_Noninjection" = "active_noninj",
                      "Nonactive_Noninjection" = "nonactive_noninj",
                      "Active_Injection" = "active_inj",
                      "Nonactive_Injection" = "nonactive_inj"),
         agegrp = ifelse(agegrp %in% unique(agegrp)[1:3], "10_24",
                         ifelse(agegrp %in% unique(agegrp)[4:7], "25_44",
                                ifelse(agegrp %in% unique(agegrp)[8:18], "45_99", "10_99"))),
         mean = readr::parse_number(adjust_to_2019),
         alpha = (mean/adjust_to_2019_2)^2,
         beta = mean/adjust_to_2019_2^2) %>%
  select(block,
         agegrp,
         sex,
         oud,
         mean,
         "sd" = adjust_to_2019_2,
         alpha,
         beta) %>% 
  filter(block %in% c("no_trt", "bup", "sublocade", "Methadone", "Naltrexone", "Detox") & 
           sex == "Male") %>% 
  mutate(block = recode(block, 
                        "bup" = "bup#sublocade#Methadone",
                        "Methadone" = "bup#sublocade#Methadone",
                        "no_trt" = "no_trt,all")) %>%
  unique() %>%
  na.omit() %>%
  separate_rows(block, sep = ",") %>%
  left_join(intake, ., by = c("agegrp", "oud", "block")) %>%
  select(File,
         block,
         agegrp,
         "sex" = sex.x,
         oud,
         "huc_mean" = healthcare_system_param1,
         "huc_sd" = healthcare_system_param2,
         "ctn_mean" = mean,
         "ctn_sd" = sd,
         alpha, 
         beta) %>%
    mutate(across(c(alpha, beta, ctn_mean, ctn_sd), function(x) ifelse(block %in% "Detox", 0, x)),
           block = recode(block,
                          "all" = "Post-bup#Post-sublocade#Post-Naltrexone#Post-Methadone#Post-Detox"))

###WRITE###
write.csv(comparison %>% 
            mutate(abs_mean_diff = abs(huc_mean - ctn_mean),
                   abs_sd_diff = abs(huc_sd - ctn_sd)), "mean_diff.csv",
          row.names = FALSE)

for (i in unique(comparison$File)){
  write.csv(comparison %>% 
              filter(File == i) %>% 
              mutate(dist = "gamma") %>%
              select(block,
                     agegrp,
                     sex,
                     oud,
                     dist,
                     "param1" = alpha,
                     "param2" = beta),
            paste0("new_", i),
            row.names = FALSE)
}


