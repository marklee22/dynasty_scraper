# dynasty_scraper
Calculate average cost of FF players for an ESPN league. ESPN averages do not account for games players missed due to injury, 
so manual calculation needs to be done via scraping.

## Script Inputs/Prompts
* League ID
* Year of the season you want stats for
* Position (These will not be standard across leagues, so you'll need to update the script appropriately)
* Start index (This is used to paginate through the list of players since ESPN limits results to 50)

### Command
```shell
ruby scrape_dynasty.rb
```

### Sample output
```
mlee@Marks-Air-3 ~ dynasty_scraper (master)$ ruby scrape_dynasty.rb 
Enter league id:
1234
Enter season to fetch stats for:
2016
Enter position to fetch stats for (QB, RB, RB_WR, WR, WR_TE, TE):
RB
Enter ranking to start at (default: 0):

Fetching RB player rankings from: http://games.espn.go.com/ffl/freeagency?leagueId=1234&teamId=10&seasonId=2016&avail=-1&slotCategoryId=2&startIndex=0

Player Name - Total Points - Total Games Played - Average Per Game
David Johnson(2508176) - 97.5 - 5 - 19.5
DeMarco Murray(14005) - 91.3 - 5 - 18.259999999999998
Ezekiel Elliott(3051392) - 90.7 - 5 - 18.14
Carlos Hyde(16777) - 80.3 - 5 - 16.06
Melvin Gordon(2576434) - 80.1 - 6 - 13.35
```
