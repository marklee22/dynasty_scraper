require "rubygems"
require "nokogiri"
require "open-uri"

qb_url = "http://games.espn.go.com/ffl/freeagency?leagueId=138744&teamId=10&seasonId=2015&avail=-1&slotCategoryId=0"
rb_url = "http://games.espn.go.com/ffl/freeagency?leagueId=138744&teamId=10&seasonId=2015&avail=-1&slotCategoryId=2"
wr_te_url = "http://games.espn.go.com/ffl/freeagency?leagueId=138744&teamId=10&seasonId=2015&avail=-1&slotCategoryId=5"
player_card_base_url = "http://games.espn.go.com/ffl/format/playerpop/overview?leagueId=138744&playerIdType=playerId&seasonId=2015&xhr=1&playerId="
nfl_base_game_log_url = "http://espn.go.com/nfl/player/gamelog/_/id/"

# TODO create player model

# # Get QB ids, names, and total points
page = Nokogiri::HTML(open(rb_url))
page.css(".pncPlayerRow").first(15).each do |player_row|
	player_node = player_row.css(".playertablePlayerName a").first
	player_id = player_node.attribute("playerid").to_s
	player_name = player_node.text
	player_total = player_row.css(".playertableStat.appliedPoints.sortedCell").first.text

	sleep(1)
	player_card_node = Nokogiri::HTML(open(player_card_base_url + player_id))
	real_player_id = player_card_node.css(".pc a:last-child").first.attribute("href").to_s.split("=")[1]

	sleep(1)
	player_game_log = Nokogiri::HTML(open(nfl_base_game_log_url + real_player_id))
	player_gp_count = player_game_log.css('.oddrow, .evenrow').length

	puts "#{player_id} - #{real_player_id} - #{player_name} - #{player_total} - #{player_gp_count}"
end

# Iterate through each line and get their game log to calculate games played

