if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse,
               cowplot)

data <- data.frame(
Parameter    = c('Fatal Overdose Rate', 'Proportion Male', 'Baseline Proportion with\nInjection Drug Use', 'Baseline Proportion with\nActive Drug Use', 'Background Mortality'),
Lower_Bound  = c(313940, 311090, 308310, 308690,320840),
Upper_Bound = c(303660, 306306, 308698, 308700, 298370),
UL_Difference = c(10280, 4784, 388, 10, 22470)
)

data2 <- data.frame(
  Parameter    = c('Fatal Overdose Rate', 'Proportion Male', 'Baseline Proportion with\nInjection Drug Use', 'Baseline Proportion with\nActive Drug Use', 'Background Mortality'),
  Lower_Bound  = c(11.68757419, 11.60846346,11.64248704, 11.51587904, 11.9676709),
  Upper_Bound = c(11.34934144, 11.42189361, 11.514832, 11.514832, 11.12901879),
  UL_Difference = c(0.33823275, 0.186569848, 0.127655034, 0.001047038, 0.838652115)
)

# original value of output
base.value <- 308696.1361
base.value2 <- 11.51517853

df1 <- data %>% 
  pivot_longer(!c(Parameter, UL_Difference), 
               values_to = "value",
               names_to = "bound") %>%
  arrange(desc(abs(UL_Difference))) %>%
  mutate(value = value - base.value,
         Parameter = factor(Parameter, ordered = TRUE,
                            levels = c("Background Mortality",
                                       "Fatal Overdose Rate",
                                       "Proportion Male",
                                       "Baseline Proportion with\nActive Drug Use",
                                       "Baseline Proportion with\nInjection Drug Use")))

g1 <- df1 %>%
  ggplot(aes(y = value,
             x = Parameter,
             fill = bound)) + 
    geom_col() + 
  scale_x_discrete(limits = rev(levels(df1$Parameter))) + 
  scale_y_continuous(breaks = c(seq(-10000, 10000, by = 5000)),
                     labels = c(scales::dollar(round(seq(base.value - 10000, base.value + 10000, by = 5000), -3)))) +
  theme_light() + 
  theme(legend.position = "none",
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 10)) + 
  scale_fill_manual(values = c("#84A9C2", "#C8D9E4")) + 
  geom_hline(yintercept = 0, linewidth = 1) +
  ggrepel::geom_label_repel(aes(label = scales::dollar(value + base.value)),
            size = 3,
            direction = "x",
            force = 8,
            force_pull = 3,
            seed = 413) +
  coord_flip() + 
  labs(y = "Discounted Total Cost per Person",
       subtitle = "Figure 3A")

df2 <- data2 %>% 
  pivot_longer(!c(Parameter, UL_Difference), 
               values_to = "value",
               names_to = "bound") %>%
  arrange(desc(abs(UL_Difference))) %>%
  mutate(value = value - base.value2,
         Parameter = factor(Parameter, ordered = TRUE,
                            levels = c("Background Mortality",
                                       "Fatal Overdose Rate",
                                       "Proportion Male",
                                       "Baseline Proportion with\nActive Drug Use",
                                       "Baseline Proportion with\nInjection Drug Use")))

g2 <- df2 %>%
  ggplot(aes(y = value,
             x = Parameter,
             fill = bound)) + 
  geom_col() + 
  scale_x_discrete(limits = rev(levels(df1$Parameter))) + 
  scale_y_continuous(breaks = c(seq(-1, 1, by = .25)),
                     labels = c(round(seq(base.value2 - 1, base.value2 + 1, by = .25), 2))) +
  theme_light() + 
  theme(legend.position = "right",
        legend.title = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(hjust = .5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size = 10)) + 
  scale_fill_manual(values = c("#84A9C2", "#C8D9E4"),
                    labels = c("Upper Bound   ", "Lower Bound")) + 
  geom_hline(yintercept = 0, linewidth = 1) +
  ggrepel::geom_label_repel(aes(label = round(value + base.value2, 2)),
                            size = 3,
                            direction = "x",
                            force = 4.5,
                            force_pull = .1,
                            show.legend = FALSE,
                            seed = 413) +
  coord_flip() +
  guides(fill = guide_legend(direction = "horizontal",
                             ncol = 1,
                             label.theme = element_text(angle = -90))) + 
  labs(y = "Discounted Quality Adjusted Life Years",
       subtitle = "Figure 3B")


g_final <- ggdraw(add_sub(plot_grid(g1, g2 + 
            theme(legend.position = "none"),
          get_legend(g2),
          nrow = 1,
          rel_widths = c(1,1,.2)),
        "Figure 3A. Sensitivity of Cost for Extended Release Buprenorphine (XR-BUP) Strategy\n
        Figure 3B. Sensitivity of Quality-Adjusted Life Years for XR-BUP Strategy",
        size = 10,
        vjust = .4))

ggsave(plot = g_final, "figure3_v2.png")


