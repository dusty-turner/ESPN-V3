base = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/"
year = "2019"
mid = "/segments/0/leagues/"
leagueID = "89417258"
tail = "?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mSettings&view=mTeam&view=modular&view=mNav&view=mMatchupScore"
url = paste0(base,year,mid,leagueID,tail)

# ESPNGet <- httr::GET(url = url,
#                      httr::set_cookies(
#                        `swid` = "{78538BF1-DE01-4269-A101-AC98E7620E27}",
#                        `espn_s2` =  "AEAysPn25UkePQCS33o3NmdRItXI0fZ7BhQFCcY020p8yCq0CDJGrlvuqAxjP42wn%2F8YZymuQOcG94GHEtkIIHnU7BWfQr6cpEKQXkcev7zKxEWiRf57PlIPEsWqIIm72dSmnL4dxW8TYufPzrIbiNZvtU0cYnLBV3nw1CAmc%2BGwghKIqRy7qPMCsSN13WibU5BHxVfxjkRttkE5Yd27cP8vAbndYor2P2FZrR%2BPVbRGThNIL8XuEJBw2rLmhqmc6tQA%2BGeNNh9dXrySFJHm72TY"
#                      ))

ESPNGet <- httr::GET(url = url)
ESPNGet$status_code
ESPNRaw <- rawToChar(ESPNGet$content)
ESPNFromJSON <- jsonlite::fromJSON(ESPNRaw)

ESPNFromJSON$schedule %>% listviewer::jsonedit()
ESPNFromJSON$teams %>% listviewer::jsonedit()


## records
TeamRecords =
tibble(
  location = ESPNFromJSON$teams$location,
  nickname = ESPNFromJSON$teams$nickname,
  teamId = ESPNFromJSON$teams$id,
  losses = ESPNFromJSON$teams$record$overall$losses,
  wins = ESPNFromJSON$teams$record$overall$wins
) %>%
  unite(Team, c(location,nickname), sep = " ")

## schedule below    
Schedule =
tibble(
winner = ESPNFromJSON$schedule$winner,
Week = ESPNFromJSON$schedule$matchupPeriodId,
AwayTeam = ESPNFromJSON$schedule$away$teamId,
AwayPoints = ESPNFromJSON$schedule$away$totalPoints,
HomeTeam = ESPNFromJSON$schedule$home$teamId,
HomePoints = ESPNFromJSON$schedule$away$totalPoints
) %>%
  left_join(TeamRecords %>% select(teamId, Team), by = c("AwayTeam"="teamId")) %>%
  select(-AwayTeam) %>%
  rename(AwayTeam = Team) %>%
  left_join(TeamRecords %>% select(teamId, Team), by = c("HomeTeam"="teamId")) %>%
  select(-HomeTeam) %>%
  rename(HomeTeam = Team) 


