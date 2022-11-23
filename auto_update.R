### Update Scores
source('update_scores.R')

### Re-Fit Model After Each Round --> new preds
<<<<<<< HEAD
# if(as.character(Sys.Date()) %in% c('2022-11-25')) {
#   source('fit_model.R')
#   source('game_preds.R')
# }
=======
if(as.character(Sys.Date()) %in% c('2022-11-24', '2022-11-28')) {
  source('fit_model.R')
  source('game_preds.R')
}
>>>>>>> 1e08681ad3da53b09a1a2f05a8ef9da335f3ae33

### Run Simulations
source('run_sim.R')

### Make Tables
# source('make_table.R')
# 
# ### Make Graphics
# source('graphics.R')

