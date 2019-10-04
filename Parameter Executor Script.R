library(tidyverse)
weeks=4
leagueID = "89417258"
year = "2019"

PositionDF =
  tibble(
    PositionId = c(1, 2, 3, 4, 5, 16),
    Position = c(
      "Quarterback",
      "Running Back",
      "Wide Receiver",
      "Tight End",
      "Kicker",
      "Defense"
    )
  )

PlayerSlotIDs = tibble(
  playerrosterslot = c(0, 2, 4, 6, 16, 17, 20, 21, 23),
  SlottedPosition = c(
    "Quarterback",
    "Running Back",
    "Wide Receiver",
    "Tight End",
    "Defense",
    "Kicker",
    "Bench",
    "IR",
    "Flex"
  )
)

teamiddf = tibble(
  id = c(1:10),
  team = c("'R'm Chair Quarterback", "Philly Chapmaniacs", "The Plainsmen", "The OBJective Functions", "Analysis Paralysis", 
           "Team Ward", "Compute This!", "The Chief", "Dallas The boys", "Palindrome Tikkit")
)

### Function Pulls and Saves All Data
gofunction = function(weeks = 3, leagueID = "89417258",year = "2019"){

playerperformance = NULL

for (i in 1:weeks) {
  base = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/"
  mid = "/segments/0/leagues/"
  tail = "?view=mMatchup&view=mMatchupScore&scoringPeriodId="
  url = paste0(base, year, mid, leagueID, tail, i)
  
  ESPNGet <- httr::GET(url = url)
  ESPNGet$status_code
  ESPNRaw <- rawToChar(ESPNGet$content)
  ESPNFromJSON <- jsonlite::fromJSON(ESPNRaw)
  # ESPNFromJSON %>% listviewer::jsonedit()
  
  ## gets players on rosters for week n
  players =
    ESPNFromJSON$teams$roster$entries %>% map("playerPoolEntry") %>% map("player") %>%
    map_df(magrittr::extract, c("id", "fullName", "defaultPositionId")) %>%
    mutate(id = as.character(id))
  
  ## number of rows of stats for each player
  observations =
    ESPNFromJSON$teams$roster$entries %>% map("playerPoolEntry") %>% map("player") %>% map("stats")  %>%
    flatten() %>% map_df( ~ count(.))
  
  playervec =
    players %>%
    mutate(observations = observations$n) %>%
    uncount(observations)

  
  ## projections and results for players withnames
  playerperformanceshort =
    ESPNFromJSON$teams$roster$entries %>% map("playerPoolEntry") %>% map("player") %>% map("stats")  %>%
    flatten() %>%
    map_df(
      magrittr::extract,
      c(
        "scoringPeriodId",
        "seasonId",
        "statSourceId",
        "statSplitTypeId",
        "id",
        "externalId",
        "appliedTotal"
      )
    ) %>%
    mutate(Player = playervec$fullName) %>%
    mutate(PositionId = playervec$defaultPositionId) %>%
    left_join(PositionDF) %>%
    mutate(iteration = i)
  
  playerperformance = bind_rows(playerperformance, playerperformanceshort)
}

playerperformance =
  playerperformance %>%
  select(-iteration, -seasonId) %>%
  distinct()

## gets team names and records
PlayerTeamDF = NULL

for (i in 1:weeks) {
  base = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/"
  # year = "2019"
  mid = "/segments/0/leagues/"
  # leagueID = "89417258"
  tail10 = "?view=mMatchup&view=mMatchupScore&scoringPeriodId="
  tail = "?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mSettings&view=mTeam&view=modular&view=mNav&view=mMatchupScore&scoringPeriodId="
  url = paste0(base, year, mid, leagueID, tail, i)
  url10 = paste0(base, year, mid, leagueID, tail10, i)
  
  ESPNGet <- httr::GET(url = url)
  ESPNGet$status_code
  ESPNRaw <- rawToChar(ESPNGet$content)
  ESPNFromJSON2 <- jsonlite::fromJSON(ESPNRaw)
  # ESPNFromJSON2 %>% listviewer::jsonedit()
  
  Sys.sleep(time = runif(1, 2, 4))
  
  ESPNGet10 <- httr::GET(url = url10)
  ESPNGet10$status_code
  ESPNRaw10 <- rawToChar(ESPNGet10$content)
  ESPNFromJSON10 <- jsonlite::fromJSON(ESPNRaw10)
  # ESPNFromJSON10 %>% listviewer::jsonedit()
  
  playerrosterslot =
    ESPNFromJSON10$teams$roster$entries %>%
    map_df(`[`, "lineupSlotId")
  
  assignedpositions =
    ESPNFromJSON10$teams$roster$entries %>%
    map("playerPoolEntry") %>% map("player") %>%
    map_df(magrittr::extract, c("id", "fullName", "defaultPositionId"))
  
  TeamPlayers =
    ESPNFromJSON10$teams$roster$entries %>% map("playerPoolEntry") %>%
    map_df( ~ count(.))
  
  PlayerTeamDFshort =
    ESPNFromJSON2$teams %>% select(location, nickname, id) %>%
    unite(Team, c(location, nickname)) %>%
    mutate(TeamPlayers = TeamPlayers$n) %>%
    uncount(TeamPlayers) %>%
    mutate(Player = assignedpositions$fullName) %>%
    select(-id) %>%
    mutate(playerrosterslot = playerrosterslot$lineupSlotId) %>%
    mutate(scoringPeriodId = i)
  
  PlayerTeamDF = bind_rows(PlayerTeamDF, PlayerTeamDFshort)
}

## adds team info to player dataframe

PlayerPerformance =
  playerperformance %>%
  left_join(PlayerTeamDF, by = c("Player", "scoringPeriodId")) %>%
  as_tibble()

WeeklyEstimates =
  PlayerPerformance %>% as.data.frame() %>%
  # filter(Team == "'R'm Chair_Quarterback") %>%
  filter(nchar(externalId) > 4) %>%
  mutate(statSourceId = if_else(statSourceId == 1, "Predicted", "Actual")) %>%
  select(
    scoringPeriodId,
    statSourceId,
    appliedTotal,
    Player,
    Position,
    Team,
    playerrosterslot
  ) %>%
  spread(statSourceId, appliedTotal) %>%
  arrange(Player) %>%
  mutate(ActualMinusPredicted = Actual - Predicted) %>%
  left_join(PlayerSlotIDs) %>%
  # filter(scoringPeriodId==1)
  # select(-playerrosterslot) %>%
  mutate(Starter = if_else(SlottedPosition %in% c("Bench", "IR"), "Bench", "Starter"))


write_csv(WeeklyEstimates, "FantasyFootballData.csv")

#### Gets standings

base = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/"
# year = "2019"
mid = "/segments/0/leagues/"
# leagueID = "89417258"
tail = "?&view=mMatchupScore&scoringPeriodId="
url = paste0(base,year,mid,leagueID,tail)

ESPNGet <- httr::GET(url = url)
ESPNGet$status_code
ESPNRaw <- rawToChar(ESPNGet$content)
ESPNFromJSON2 <- jsonlite::fromJSON(ESPNRaw)
# ESPNFromJSON2 %>% listviewer::jsonedit()

season1 = tibble(
  awayid = ESPNFromJSON2$schedule$away$teamId,
  awaypoints = ESPNFromJSON2$schedule$away$totalPoints,
  homeid = ESPNFromJSON2$schedule$home$teamId,
  homepoints = ESPNFromJSON2$schedule$home$totalPoints,
  winner = ESPNFromJSON2$schedule$winner,
  weekID = ESPNFromJSON2$schedule$matchupPeriodId
) %>%
  left_join(teamiddf, by = c("awayid"="id")) %>%
  rename(AwayTeam = team) %>%
  left_join(teamiddf, by = c("homeid"="id")) %>%
  rename(HomeTeam = team) %>%
  mutate(winner = if_else(awaypoints>homepoints,AwayTeam,HomeTeam))


season =
season1 %>% select(-awayid,-homeid) %>%
  gather(Location, Points, -winner, -weekID, -AwayTeam,-HomeTeam) %>%
  arrange(weekID) %>%
  group_by(weekID) %>%
  mutate(rank = rank(-Points)) %>%
  mutate(EWETL = rank-1) %>%
  mutate(EWETW = 10-rank) %>%
  group_by()

season %>%
write_csv("weekbyweekresults.csv")

season1 %>%
write_csv("weekbyweekresultssimple.csv")

}

gofunction(weeks = 4, leagueID = leagueID, year = year)

###HTML Documents
WeeklyEstimates = read_csv("FantasyFootballData.csv")
WeeklyEstimates$Team  %>% unique() %>% na.omit() -> teamlist
currentweek = 4
for (i in 1:10) {
  rmarkdown::render("Fantasy Football Team Report.Rmd",params=list(team=teamlist[i],week = currentweek))
  file.rename(from="Fantasy-Football-Team-Report.html", to =paste0(teamlist[i],"_Update_week", currentweek, ".html"))
  file.copy(from=paste0(getwd(),"/",teamlist[i], "_Update_week",currentweek,".html"), to = paste0(getwd(),"/FF Update Reports/",teamlist[i]," Update_week", currentweek, ".html"), overwrite = TRUE)
  file.remove(paste0(getwd(),"/",teamlist[i],"_Update_week",currentweek,".html"))
}

