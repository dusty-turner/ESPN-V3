library(tidyverse)
library(httr)
library(httpuv)
library(XML)
library(jsonlite)
library(stringr)

# I can go to this URL in any browser (when I'm not logged into my account) and 
# I can retrieve the information at the API
# It also works when I execute the GET function

url = "https://fantasy.espn.com/apis/v3/games/ffl/leagueHistory/1314476?seasonId=2018"

# For the URLs below, I can access the API in a browser only if I'm logged into ESPN.  
# However, if I'm not logged in, I cannot access the API
# I think its because of that, I cannot access any of these using the GET command

url = "https://fantasy.espn.com/football/league?leagueId=1314476"

# url = "https://fantasy.espn.com/apis/v3/games/ffl/leagueHistory/1314476?seasonId=2018"
# url = "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2018/segments/0/leagues/1314476"
# url = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/2018/segments/0/leagues/1314476?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mSettings&view=mTeam&view=modular&view=mNav"
url = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/2018/segments/0/leagues/1314476?view=mDraftDetail"

# Because I cannot access them, I have been trying to use the information from Steve Morse's python blog 
# (https://stmorse.github.io/journal/espn-fantasy-v3.html)
# about passing the cookies.  I used the stack overflow post below to figure out how to pass cookies in r 
# (https://stackoverflow.com/questions/26441865/how-to-properly-set-cookies-to-get-url-content-using-httr)

# Frustratingly, the status code keeps coming back as '404' instead of '200'

# Any thoughts?

ESPNGet <- httr::GET(url = url,
                     httr::set_cookies(
                       `swid` = "{78538BF1-DE01-4269-A101-AC98E7620E27}",
                       # `espn_s2` =  "AEApb0uQ8G8n4ctyLyLuqQyfezcBz3%2BHq6RVbmZmpp%2F3cUGtNw7G%2BDY8OeSM31R%2Bd0%2FwhDFwZOCfq85jHvQwU5e3YgvhFdyB%2BR0ZUKOgurbplOk1EKkNxkVJkCIeYjHdZkhgnSzBIWp4uVuqtj698G%2Fc5cJd71KvFSe4c%2Bk%2BTte8StGMdMLAwH68XbZZWB928u9V547HsnRGHMED%2BTv85l37kq4bLo0qO40YvjRETQdFxrtnZGGMKczFswTBSiCTvTvPafLpt9JPM%2FBU0tzXatSl"
                       `espn_s2` =  "AEAysPn25UkePQCS33o3NmdRItXI0fZ7BhQFCcY020p8yCq0CDJGrlvuqAxjP42wn%2F8YZymuQOcG94GHEtkIIHnU7BWfQr6cpEKQXkcev7zKxEWiRf57PlIPEsWqIIm72dSmnL4dxW8TYufPzrIbiNZvtU0cYnLBV3nw1CAmc%2BGwghKIqRy7qPMCsSN13WibU5BHxVfxjkRttkE5Yd27cP8vAbndYor2P2FZrR%2BPVbRGThNIL8XuEJBw2rLmhqmc6tQA%2BGeNNh9dXrySFJHm72TY"
                     ))
  
ESPNGet$status_code
# ESPNGet <- httr::GET(url = url)
ESPNRaw <- rawToChar(ESPNGet$content)
ESPNFromJSON <- jsonlite::fromJSON(ESPNRaw)


# ESPNGet <- httr::GET("http://httpbin.org/cookies/set")


fake = httr::GET("http://smida.gov.ua/db/emitent/year/xml/showform/32153/125/templ", 
    httr::set_cookies(`_SMIDA` = "7cf9ea4bfadb60bbd0950e2f8f4c279d",
                `__utma` = "29983421.138599299.1413649536.1413649536.1413649536.1",
                `__utmb` = "29983421.5.10.1413649536",
                `__utmc` = "29983421",
                `__utmt` = "1",
                `__utmz` = "29983421.1413649536.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)"))

fakeRaw <- rawToChar(fake$content)
fakeFromJSON <- jsonlite::fromJSON(fakeRaw)



h <- curl::new_handle()
req <- curl::curl_fetch_memory("https://eu.httpbin.org/cookies/set?baz=moooo", handle = h)
curl::handle_cookies(h)


ESPNGet <- httr::GET(url = url,
                     httr::set_cookies(
                       # `SWID` = "{78538BF1-DE01-4269-A101-AC98E7620E27}",
                       `SWID` = "{78538BF1-DE01-4269-A101-AC98E7620E27}",
                       # `espn_s2` = "AEBZmBpUHTX%2Ftyd%2FbxSo4PWgRYVw35KJDpx8PUsvgygvTdjeaRCOuVq1kE8XhajigCj%2FCh1x%2FjbrG0DF5DRuXIUmU9%2FgAqAo65mJK784dOXoBR0ujs88i%2BiQc2JG2m%2F2%2FLy90ODnytwdelxvL81vu%2FC80IWF6pra2Q3f8VLJLZdV5isuBGgExmEr1vPm2GrO9QZcPt8Oo2tMWJaMyK4PmYoa5usWi2U31LKqaXos6W1T5TJfe0z4rLlazHpcSwhi0M1UwMqsv0p%2Fmb38WStXsU4q"
                       `espn_s2` = "AEApb0uQ8G8n4ctyLyLuqQyfezcBz3%2BHq6RVbmZmpp%2F3cUGtNw7G%2BDY8OeSM31R%2Bd0%2FwhDFwZOCfq85jHvQwU5e3YgvhFdyB%2BR0ZUKOgurbplOk1EKkNxkVJkCIeYjHdZkhgnSzBIWp4uVuqtj698G%2Fc5cJd71KvFSe4c%2Bk%2BTte8StGMdMLAwH68XbZZWB928u9V547HsnRGHMED%2BTv85l37kq4bLo0qO40YvjRETQdFxrtnZGGMKczFswTBSiCTvTvPafLpt9JPM%2FBU0tzXatSl"
                       # `espn_s2` = "AECyIRDHlzxGz%2F%2Bk0YlPw4M2ERyNRiLB1HrN0HNF1jXqEgH8KzgM9cD3mHtzkwv0sgmJkdM5aS%2BzF0dSKrnMLoV49I%2BaV7rkCArwguGqIpJgAzJMy33GYwG9PuHJuM8fU1IRFlhH7TSErMmWfJpsuQZUYGHqJ13WG8gQtgTU1TwN%2FIACiZy2tj3bu6BuWDtpTBmFgYKjdBeX08sUdct2VL3KGmkOEjJ4rF97taDG%2BuPT3ib8O0Ao37uDaqzFR89FcQFU0%2FrcyvUMzKYV5jfGX6xA"
                       # `espn_s2` = "AECyIRDHlzxGz%2F%2Bk0YlPw4M2ERyNRiLB1HrN0HNF1jXqEgH8KzgM9cD3mHtzkwv0sgmJkdM5aS%2BzF0dSKrnMLoV49I%2BaV7rkCArwguGqIpJgAzJMy33GYwG9PuHJuM8fU1IRFlhH7TSErMmWfJpsuQZUYGHqJ13WG8gQtgTU1TwN%2FIACiZy2tj3bu6BuWDtpTBmFgYKjdBeX08sUdct2VL3KGmkOEjJ4rF97taDG%2BuPT3ib8O0Ao37uDaqzFR89FcQFU0%2FrcyvUMzKYV5jfGX6xA"
                     ))
