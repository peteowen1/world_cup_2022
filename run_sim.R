### World Cup Simulations
library(tidyverse)
library(furrr)
options(future.fork.enable = TRUE)
options(dplyr.summarise.inform = FALSE)
plan(multisession) #plan(multicore(workers = parallel::detectCores()-1))
source('helpers.R')

### Simulation Parameters
n_sims <- 1000
set.seed(12345)
<<<<<<< HEAD
run_date <- Sys.Date() #as.Date('2022-11-20')
=======
run_date <- Sys.Date() 
>>>>>>> a9f48bd56a7186f132c8c4b56f5de99149230013

### Coefficients
#posterior <- read_rds('model_objects/posterior.rds')
home_field <- 0.3 #mean(posterior$home_field)
neutral_field <- 0.15  #mean(posterior$neutral_field)
mu <- 0.05 # mean(posterior$mu)

### Read in Ratings and Schedule
df_ratings <- read_csv('predictions/ratings.csv') %>%
  mutate(alpha = alpha * 1,
         delta = delta / 1,
         net_rating = alpha - delta)

schedule <- 
  read_csv('data/schedule.csv') %>% 
<<<<<<< HEAD
  mutate('date' = as.Date(date, '%m/%d/%y')) %>% 
  mutate('team1_score' = if_else(date >= run_date, NA_real_, team1_score),
         'team2_score' = if_else(date >= run_date, NA_real_, team2_score)) %>% 
=======
  mutate('date' = as.Date(date, '%m/%d/%y')) %>%
  mutate('team1_score' = ifelse(date > run_date, NA, team1_score),
         'team2_score' = ifelse(date > run_date, NA, team2_score)) %>%
>>>>>>> a9f48bd56a7186f132c8c4b56f5de99149230013
  mutate('team1_score' = case_when(is.na(shootout_winner) ~ as.numeric(team1_score),
                                   shootout_winner == team1 ~ 0.1 + team1_score,
                                   shootout_winner == team2 ~ -0.1 + team1_score))
### Expected Score for Each Game
schedule <- adorn_xg(schedule)

### Simulate Group Stage
df_group_stage <- filter(schedule, !is.na(group))
tictoc::tic()
if(any(is.na(schedule$team1_score[1:48]))) {
  dfs_group_stage <- map(1:n_sims, ~df_group_stage)
  group_stage_results <- 
    future_map(dfs_group_stage, ~sim_group_stage(.), 
               .options = furrr_options(seed = 12921))
  
  ### Knockout Round
  knockout_brackets <- 
    future_map(group_stage_results, ~build_knockout_bracket(.x$standings),
               .options = furrr_options(seed = 31121))
}  else {
  knockout_brackets <- future_map(1:n_sims, ~filter(schedule,  str_detect(ko_round, 'R16'))) 
  gsr <- sim_group_stage(df_group_stage)
  group_stage_results <- map(1:n_sims, ~gsr)
}
tictoc::toc()

### R16
tictoc::tic()
knockout_brackets_r16 <- 
  future_map(knockout_brackets, ~{
    schedule %>% 
      filter(str_detect(ko_round, 'R16')) %>% 
      mutate('team1' = if_else(is.na(.$team1), .x$team1, .$team1),
             'team2' = if_else(is.na(.$team2), .x$team2, .$team2)) %>% 
      select(-lambda_1, -lambda_2) %>% 
      adorn_xg(.)
  })

r16_results <- future_map(knockout_brackets_r16, sim_ko_round, .options = furrr_options(seed = TRUE))
tictoc::toc()

### QF
tictoc::tic()
knockout_brackets_qf <- 
  future_map(r16_results, ~{
    winners <- if_else(.x$team1_score > .x$team2_score, .x$team1, .x$team2)
    schedule %>% 
      filter(str_detect(ko_round, 'QF')) %>% 
      mutate('team1' = map_chr(1:nrow(.), ~if_else(is.na(.data$team1[.x]), winners[2 * .x - 1], .data$team1[.x])),
             'team2' = map_chr(1:nrow(.), ~if_else(is.na(.data$team2[.x]), winners[2 * .x], .data$team2[.x]))) %>% 
      select(-lambda_1, -lambda_2) %>% 
      adorn_xg(.)
  })

qf_results <- future_map(knockout_brackets_qf, sim_ko_round, .options = furrr_options(seed = TRUE))
tictoc::toc()

### SF
tictoc::tic()
knockout_brackets_sf <- 
  future_map(qf_results, ~{
    winners <- if_else(.x$team1_score > .x$team2_score, .x$team1, .x$team2)
    schedule %>% 
      filter(str_detect(ko_round, 'SF')) %>% 
      mutate('team1' = winners[c(1,3)],
             'team2' = winners[c(2,4)]) %>% 
      select(-lambda_1, -lambda_2) %>% 
      adorn_xg(.)
  })

sf_results <- future_map(knockout_brackets_sf, sim_ko_round, .options = furrr_options(seed = TRUE))
tictoc::toc()

### Finals
tictoc::tic()
knockout_brackets_final <- 
  future_map(sf_results, ~{
    winners <- if_else(.x$team1_score > .x$team2_score, .x$team1, .x$team2)
    schedule %>% 
      filter(str_detect(ko_round, 'FINAL')) %>% 
      mutate('team1' = winners[c(1)],
             'team2' = winners[c(2)]) %>% 
      select(-lambda_1, -lambda_2) %>% 
      adorn_xg(.)
  })

finals_results <- future_map(knockout_brackets_final, sim_ko_round, .options = furrr_options(seed = TRUE))
tictoc::toc()

### Aggregate Results
qf_teams <- bind_rows(qf_results) %>% pivot_longer(c('team1', 'team2')) %>% pull(value)
sf_teams <- bind_rows(sf_results) %>% pivot_longer(c('team1', 'team2')) %>% pull(value)
final_teams <- bind_rows(finals_results) %>% pivot_longer(c('team1', 'team2')) %>% pull(value)
winners <- bind_rows(finals_results) %>% mutate('champ' = if_else(team1_score > team2_score, team1, team2)) %>% pull(champ)

df_stats <- 
  map_dfr(group_stage_results, ~.x$standings) %>% 
  group_by(team, group) %>% 
  summarise('mean_pts' = mean(points),
            'mean_gd' = mean(goal_diff),
            'mean_gf' = mean(goals_scored),
            'mean_ga' = mean(goals_allowed),
            'r16' = mean(progress),
            'qf' = sum(team == qf_teams)/n_sims,
            'sf' = sum(team == sf_teams)/n_sims,
            'finals' = sum(team == final_teams)/n_sims,
            'champ' = sum(team == winners)/n_sims) %>% 
  ungroup()

### Save Results
write_csv(df_stats, 'predictions/sim_results.csv')

### Track History
if(!file.exists('predictions/history.csv')) {
  df_stats %>% 
    mutate('date' = run_date) %>% 
    write_csv('predictions/history.csv')
}
history <- 
  read_csv('predictions/history.csv', skip = 0) %>% 
  filter(date != lubridate::as_date(run_date)) %>% 
  bind_rows(df_stats %>% mutate('date' = run_date)) %>% 
  arrange(date)

<<<<<<< HEAD
write_csv(history, 'predictions/history.csv')
=======
write_rds(map(group_stage_results, .x$standings), 'predictions/sim_rds/group_stage_results.rds')
write_rds(map(group_stage_results, .x$results), 'predictions/sim_rds/group_stage_game_results.rds')
write_rds(r16_results, 'predictions/sim_rds/r16_results.rds')
write_rds(qf_results, 'predictions/sim_rds/qf_results.rds')
write_rds(sf_results, 'predictions/sim_rds/sf_results.rds')
write_rds(finals_results, 'predictions/sim_rds/finals_results.rds')
>>>>>>> a9f48bd56a7186f132c8c4b56f5de99149230013
