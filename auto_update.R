### Update Scores
source('update_scores.R')

<<<<<<< HEAD
### Re-Fit Model After Each Round --> new preds

# if(as.character(Sys.Date()) %in% c('2022-11-25')) {
#   source('fit_model.R')
#   source('game_preds.R')
# }
# 
# if(as.character(Sys.Date()) %in% c('2022-11-24', '2022-11-28')) {
#   source('fit_model.R')
#   source('game_preds.R')
# }

=======
>>>>>>> a9f48bd56a7186f132c8c4b56f5de99149230013
### Run Simulations
source('run_sim.R')

### Make Tables
# source('make_table.R')
# 
# ### Make Graphics
# source('graphics.R')

## Re-Fit Model After Each Round --> new preds
if(as.character(Sys.Date()) %in% c('2022-11-24', '2022-11-28')) {
  source('fit_model.R')
  source('game_preds.R')
}