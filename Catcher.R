pacman::p_load(tidyverse,
               data.table)

n = 100000
allocation <- vector(length = n)
key_pair = fread("key.csv")

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
    allocation <- rgamma(n, (param1/param2)^2, param1/param2^2)
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
    rename(`PSA spreadsheet` = File) %>%
    as.data.frame() %>%
    unnest(cols = c(dist, alpha, beta, mu, sigma)) %>%
    mutate(dist = as.character(dist),
           alpha_temp = ifelse(dist == "norm", (alpha/beta)^2, NA_character_),
           beta = ifelse(dist == "norm", alpha/beta^2, beta),
           alpha = ifelse(dist == "norm", alpha_temp, alpha),
           dist = ifelse(dist == "norm", "norm to gamma", dist)) %>%
    select(-alpha_temp) %>%
    left_join(., key_pair) %>%
    unique() %>% 
    select(dist, alpha, beta, mu, sigma, 
           `PSA spreadsheet`, block, agegrp, sex, oud,
           `Matching Base Case Spreadsheet`)

  return(strat)
}

for (i in 1:3){
  write.csv(as.matrix(
    compare.distros(
      paste0("Strat", i)
    )
  ), file = paste0("strat", i, "_update.csv"))
}

