#### africa/asian/north america
library(data.table)

aanm_teams <- tibble(team1 = c('Qatar','Senegal','United States','Iran','Mexico',
                               'Saudi Arabia','Tunisia','Japan','Morocco',#'Australia',#'Costa Rica',
                               'Cameroon','Canada','South Korea','Ghana'))


qfs_df <- rbindlist(knockout_brackets_qf, idcol=TRUE) %>% as_tibble()

qf_tms <- bind_rows(qfs_df %>% select(.id,team1),qfs_df %>% select(.id,team1 = team2)) %>%
  left_join(aanm_teams, keep = TRUE) #%>% view()

qf_tms %>% 
  group_by(.id) %>% 
  summarise(aanm = sum(ifelse(is.na(team1.y),0,1))) %>% 
  group_by(aanm) %>%
  summarise(prop = n()/n_sims) #%>% count(is.na(aanm))

###
if (is.atomic(aanm_teams)==FALSE) {
  aanm_teams <- as.vector(aanm_teams$team1)  
}

aanm_dfz <- df_stats %>% filter(team %in% aanm_teams) %>% mutate(no_qf = 1-qf)

1 - prod(aanm_dfz$no_qf)

########### france brazil win all group games
groups_df <- rbindlist(group_stage_results, idcol=TRUE) %>% as_tibble()

groups_df <- groups_df %>% mutate(france_3win = if_else(team == 'France' & points == 9,1,0),
                                  brazil_3win = if_else(team == 'Brazil' & points == 9,1,0))

frbr_sims <- groups_df %>% group_by(.id) %>% summarise(fra = sum(france_3win),
                                                       bra = sum(brazil_3win),
                                                       tot = fra + bra)


####### no surprise for final
final_df <- rbindlist(finals_results, idcol=TRUE) %>% as_tibble()

final_df <- final_df %>% mutate(expected_final = case_when(team1 %in% c('Brazil','France','Argentina','Spain') &
                                                             team2 %in% c('Brazil','France','Argentina','Spain') ~ 1,
                                                           TRUE ~ 0))

summary(final_df$expected_final)
