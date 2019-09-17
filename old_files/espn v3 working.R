url = "http://fantasy.espn.com/apis/v3/games/ffl/seasons/2018/segments/0/leagues/1314476?view=mDraftDetail"

cookies <- c(`swid` = "{78538BF1-DE01-4269-A101-AC98E7620E27}",
             `espn_s2` =  "AEAysPn25UkePQCS33o3NmdRItXI0fZ7BhQFCcY020p8yCq0CDJGrlvuqAxjP42wn%2F8YZymuQOcG94GHEtkIIHnU7BWfQr6cpEKQXkcev7zKxEWiRf57PlIPEsWqIIm72dSmnL4dxW8TYufPzrIbiNZvtU0cYnLBV3nw1CAmc%2BGwghKIqRy7qPMCsSN13WibU5BHxVfxjkRttkE5Yd27cP8vAbndYor2P2FZrR%2BPVbRGThNIL8XuEJBw2rLmhqmc6tQA%2BGeNNh9dXrySFJHm72TY"
)

cookie <- paste(names(cookies), cookies, sep = "=", collapse = ";")

ESPNGet <- httr::GET(url = url,
                     config = httr::config(cookie = cookie))

ESPNGet$status_code

ESPNRaw <- rawToChar(ESPNGet$content)
ESPNFromJSON <- jsonlite::fromJSON(ESPNRaw)
