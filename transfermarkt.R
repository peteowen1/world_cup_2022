library(rvest)
library(tidyverse)

url <- "https://www.transfermarkt.com/weltmeisterschaft-2022/teilnehmer/pokalwettbewerb/WM22/saison_id/2021"

team_data_page <- tryCatch(xml2::read_html(url), error = function(e) NA)
links <- team_data_page %>% html_elements("a") %>% html_attr("href") 
links <- links[!is.na(links)]
links <- links[str_detect(links,"verein")] %>% unique() 
links
wc_links <- links[1:32]

team_scrape <- function(team_url){
  team_df <- read_html(glue::glue('https://www.transfermarkt.com{team_url}')) %>% html_table()
  team_df <- team_df[[2]]
  team_df <- team_df %>% janitor::clean_names() %>% filter(!is.na(club)) 
  
  team_df$val2 <- gsub("Th", "000", team_df$x_4)
  team_df$val2 <- gsub("m", "0000", team_df$val2)
  team_df$val2 <- gsub("\\.", "", team_df$val2)
  team_df$value_cur <- formattable::currency(team_df$val2)
  team_df$adj_value <- as.numeric( team_df$value_cur)*1.11^(team_df$x_2-26)
  team_df$team <- str_split(team_url, "/")[[1]][2]
  team_df <- team_df %>% select(number,player,team,position = club,age = x_2,value_cur,adj_value)
  
  print(team_url)
  return(team_df)
}

tot_plyr_df <- purrr::map_dfr(wc_links , ~team_scrape(.))

tot_plyr_df$adj_value <- as.numeric( tot_plyr_df$value_cur)*1.11^(tot_plyr_df$age-26)

###
tot_plyr_df %>% group_by(team) %>% summarise(tot_val = sum(adj_value), plyrs = n(), avg_val = tot_val/plyrs) %>% view()


