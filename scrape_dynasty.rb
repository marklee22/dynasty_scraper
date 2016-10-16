require "rubygems"
require "nokogiri"
require "open-uri"

class DynastyScraper
  ESPN_FANTASY_BASE_URL = "http://games.espn.go.com/ffl"
  ID_GAME_LOG_BASE_URL = "http://espn.go.com/nfl/player/gamelog/_/id"
  DELIMITER = " - "
  NUM_PLAYERS_TO_PROCESS = 5  # Update to process more players
  TIME_BETWEEN_REQUESTS = 0.25  # Update to process stats faster

  POSITIONS_TO_CATEGORIES_MAP = {
    :QB => 0,
    :RB => 2,
    :RB_WR => 3,
    :WR => 4,
    :WR_TE => 5,
    :TE => 6
  }

  def initialize(leagueId, year, positionType, startIndex)
    @leagueId = leagueId
    @year = year
    @positionType = positionType
    @startIndex = startIndex
  end

  # Gets all the supported position categories
  def self.get_supported_position_types
    buffer = ""
    POSITIONS_TO_CATEGORIES_MAP.each do |position, category|
      buffer += position.to_s + ", "
    end

    buffer.chomp(", ")
  end

  # Scrapes ESPN to get player rankings and actual game played averages for fantasy points scored
  def get_position_player_rankings
    url = position_url(@positionType)
    puts "Fetching #{@positionType.to_s} player rankings from: #{url}"
    puts
    puts "Player Name#{DELIMITER}Total Points#{DELIMITER}Total Games Played#{DELIMITER}Average Per Game"

    page = Nokogiri::HTML(open(url))

    page.css(".pncPlayerRow").first(NUM_PLAYERS_TO_PROCESS).each do |player_row|
      playerNode = player_row.css(".playertablePlayerName a").first
      playerId = playerNode.attribute("playerid").to_s
      playerName = playerNode.text
      totalPoints = player_row.css(".playertableStat.appliedPoints.sortedCell").first.text

      sleep(TIME_BETWEEN_REQUESTS)
      playerCardNode = Nokogiri::HTML(open(player_card_url(playerId)))
      realPlayerId = playerCardNode.css(".pc a:last-child").first.attribute("href").to_s.split("=")[1]

      sleep(TIME_BETWEEN_REQUESTS)
      playerGameLog = Nokogiri::HTML(open(player_game_log_by_year_url(realPlayerId)))
      totalGamesPlayed = playerGameLog.css('.oddrow, .evenrow').length
      perGameAverage = totalPoints.to_f / totalGamesPlayed.to_i

      # TODO create player model instead
      puts "#{playerName}(#{realPlayerId})#{DELIMITER}#{totalPoints}#{DELIMITER}" +
        "#{totalGamesPlayed}#{DELIMITER}#{perGameAverage}"
    end
  end

  private

    # Generates the ESPN "player pop up card" url. This is used to fetch the real player id to get game logs for.
    def player_card_url(playerId)
      "#{ESPN_FANTASY_BASE_URL}/format/playerpop/overview?leagueId=#{@leagueId}&playerIdType=playerId" +
        "&seasonId=#{@year}&xhr=1&playerId=#{playerId}"
    end

    # Generates the ESPN player game log url to calculate number of games played without injury.
    def player_game_log_by_year_url(playerId)
      "#{ID_GAME_LOG_BASE_URL}/#{playerId}/year/#{@year}"
    end

    # Generates the ESPN league page for position rankings
    def position_url(positionType)
      positionCategoryId = POSITIONS_TO_CATEGORIES_MAP[@positionType]
      "#{ESPN_FANTASY_BASE_URL}/freeagency?leagueId=#{@leagueId}&teamId=10&seasonId=#{@year}" +
        "&avail=-1&slotCategoryId=#{positionCategoryId.to_s}&startIndex=#{@startIndex.to_s}"
    end
end

# Prompt for variables
# TODO error check for unsupported inputs
puts "Enter season to fetch stats for:"
year = gets.chomp
puts "Enter position to fetch stats for (#{DynastyScraper.get_supported_position_types}):"
positionType = gets.chomp
puts "Enter ranking to start at (default: 0):"
startIndex = gets.chomp

startIndex = startIndex.empty? ? 0 : startIndex

DynastyScraper.new(138744, year, positionType.to_sym, startIndex)
  .get_position_player_rankings
