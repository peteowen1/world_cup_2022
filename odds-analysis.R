##### aanm
library(tidyverse)

aanm_teams <- c('Morocco','Mexico','Japan','USA','Senegal','Canada','South Korea','Tunisia','Saudi Arabia','Iran','Cameroon','Ghana','Qatar')

aanm_df <- data.table::rbindlist(knockout_brackets_qf, idcol = TRUE) %>% 
  pivot_longer(c('team1', 'team2')) %>% 
  mutate(aanm = if_else(value %in% aanm_teams,1,0))


aanm_df %>% 
  group_by(.id) %>% 
  summarise(aanm_value = sum(aanm)) %>%
  group_by(aanm_value) %>% count()/n_sims


df_stats <- df_stats %>% filter(team %in% aanm_teams) %>%
mutate(no_qf = 1-qf)

df_stats %>% select(team,qf)

1-prod(df_stats$no_qf)

aanm_df %>% 
  group_by(.id) %>% 
  summarise(aanm_value = sum(aanm)) %>%
  filter(aanm_value == 0) %>% 
  summarise(make_qf = (n_sims - n())/n_sims)
                                        
            