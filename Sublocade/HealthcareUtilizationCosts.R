if(!require(pacman)) install.packages(pacman)
pacman::p_load(tidyverse,
               data.table)

intake <- lapply(list.files(path = "huc_priors/", 
                            full.names = TRUE),
                 fread) %>% 
  rbindlist(., idcol = "File", fill = TRUE) %>% 
  mutate(File = factor(File, 
                       labels = c(list.files(path = "huc_priors/"))))%>% 
  mutate(alpha = (healthcare_system_param1/healthcare_system_param2)^2,
         beta = healthcare_system_param1/healthcare_system_param2^2)

comparison <- fread("healthcare utilization CTN.csv")
