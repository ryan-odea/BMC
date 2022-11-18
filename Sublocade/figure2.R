!if(require(pacman)) install.packages(pacman)
pacman::p_load(tidyverse,
               data.table,
               magrittr)

#ICER##################
#######################
output.intake <- function(label = c(1, 2)) {
  output_raw <- lapply(list.files(path = paste0("output", label), 
                                  full.names = TRUE), 
                       fread) %>% 
    rbindlist(idcol = "CE Output")
  
  output_data <- output_raw %>%
    mutate(life = as.numeric(ifelse(V1 == "utility_minimal",
                         discounted_total/52, NA_character_)),
           hsc = as.numeric(ifelse(V1 == "healthcare_system_cost",
                        discounted_total, NA_character_))) %>%
    filter(V1 %in% c("utility_minimal", "healthcare_system_cost")) %>% 
    group_by(`CE Output`) %>% 
    fill(life:hsc, .direction = "downup") %>% 
    slice(1) %>%
    ungroup() %>%
    arrange(hsc) %>% 
    mutate(cost_change = hsc - lag(hsc),
           qaly_change = life - lag(life),
           icer = cost_change/qaly_change) %>%
    select(cost_change,
           qaly_change,
           icer,
           hsc,
           "qaly" = life,
           "run_num" = `CE Output`)
  
  return(output_data)
}
#COMPARISON LOGIC###########
############################

data <- lapply(c(1, 2), output.intake)
  colnames(data[[1]]) %<>% paste0("_tmucos_bup")
  colnames(data[[2]]) %<>% paste0("_xr_bup")
  
    id_pull <- cbind(data[[1]], data[[2]]) %>% 
      filter(icer_tmucos_bup <= 100000) %>% 
      filter(hsc_xr_bup <= hsc_tmucos_bup | qaly_xr_bup >= qaly_tmucos_bup) %>%
      mutate(dom = "XR-BUP") %>%
      select("id" = run_num_xr_bup,
             dom)

#SYMBOL TABLE###############
############################
symbol_table <- data.frame(id = 1:100,
                    A = rep(seq(.1, 1, by = .1), times = 10),
                    B = rep(seq(.1, 1, by = .1), each = 10)) %>% 
      left_join(., id_pull, by = "id") %>% 
      mutate(dom = ifelse(is.na(dom), "T-MUCOS-BUP", dom)) %>% 
      mutate(A = (((0.953 + (1-A)*0.047)^26)/0.953^26-1),
             B = 1 - B)
    

#PLOT######################
###########################
symbol_table %>% 
      ggplot(., aes(x = A, y = B, col = dom)) + 
      geom_point(size = 6) + 
      theme_light() + 
      scale_color_manual(labels = c("T-MUCOS-BUP       ", "XR-BUP"),
                         values = c("#3D627B", "#9FBCD0")) + 
      scale_y_continuous(labels = scales::percent_format()) + 
      scale_x_continuous(labels = scales::percent_format()) + 
      labs(x = "6-Month Percent Increase in Retention",
           y = "Pharmaceutical Cost Decrease of XR-BUP",
           color = "",
           caption = "T-MUCOS-BUP is Transmucosal Buprenorphine\n
           XR-BUP is Extended Release Buprenorphine") + 
      guides(color = guide_legend(direction = "horizontal",
                                 ncol = 1,
                                 label.theme = element_text(angle = -90))) + 
      theme(plot.caption = element_text(hjust = 0.5))
                    