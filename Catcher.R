pacman::p_load(tidyverse,
               data.table)

n = 100000
key_pair = fread("key.csv")
strategy = "Strat2"

#INTAKE=======================
intake <- function(subdirectory) {
  intake_raw <<- lapply(list.files(path = paste0(subdirectory), 
                                  full.names = TRUE), 
                       fread) %>%
    rbindlist(., idcol = "File", fill = TRUE) %>%
    mutate(File = factor(File, 
                         labels = c(list.files(path = paste0(subdirectory,"/")))))
  
}
#DRAW DISTRIBUTION=============
distribute <- function(param1, param2, n, distribution = c("gamma", "beta", "unif", "lnorm", "norm")){
  if (distribution == "gamma"){
    allocation <- rgamma(n, param1, param2) 
  } else if (distribution == "beta"){
    allocation <- rbeta(n, param1, param2)
  } else if (distribution == "unif"){
    allocation <- runif(n, param1, param2)
  } else if (distribution == "lnorm"){
    allocation <- rlnorm(n, param1, param2)
  } else if (distribution == "norm"){
    allocation <- rnorm(n, param1, param2)
  } else tryCatch(print("Please select a distribution from either gamma, beta, log-normal, or uniform"))
  
  summary <- data.frame(dist = distribution,
                        alpha = param1,
                        beta = param2,
                        mu = mean(allocation),
                        sigma = sd(allocation))
  
  return(summary)
}
#DISTRIBUTION CHECK===============
check.dist <- function(intake){
  distros <- t(mapply(distribute, 
                      param1 = intake$param1, 
                      param2 = intake$param2, n = n, 
                      distribution = intake$distribution)) %>%
    as.data.table()
  
  return(distros)
}

compare.distros <- function(strategy = c("Strat1", "Strat2", "Strat3")){
  strat <- intake(subdirectory = strategy) %>% 
    check.dist() %>% 
    cbind(intake_raw) %>% 
    select(`PSA spreadsheet` = File,
           alpha, beta,
           dist, mu, sigma) %>% 
    left_join(., key_pair) %>% 
    as.data.frame() %>%
    unique()
  
  return(strat)
}

s <- compare.distros("Strat2")


