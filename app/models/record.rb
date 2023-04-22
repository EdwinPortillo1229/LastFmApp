class Record < ApplicationRecord

  def get_lastfm_data
    user_data = Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=#{self.username}&api_key=11f12d6b2aae4b2b41e2abc116d687fd&format=json"))
    if user_data.code == "404"
      return nil
    end

    data = case self.data_type
    when 'artists'
      self.get_top_artists
    when 'albums'
      self.get_top_albums
    when 'songs'
      self.get_top_albums
    end
    data
  end

  def get_all_songs(first_page, username, from_date, to_date, api_key)
    songs = []
    pages = first_page["recenttracks"]["@attr"]["totalPages"].to_i

    while pages >= 1
      res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{username}&page=#{pages}&limit=200&from=#{from_date}&to=#{to_date}&api_key=#{api_key}&format=json")).body)
      res["recenttracks"]["track"].each do |track|
        songs << {
          "unaltered_name" => track["name"],
          "unaltered_artist" => track["artist"]["#text"],
          "unalter_album" => track["album"]["#text"],
          "name" =>  track["name"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
          "artist" => track["artist"]["#text"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
          "album" => track["album"]["#text"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
        }
      end
    end
    songs
  end

  def get_top_artists(username, time, api_key)
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopArtists&user=#{username}&period=#{time}&api_key=#{api_key}&format=json")).body)
    artists = []
    res["topartists"]["artist"].each do |a|
      artists << [a["name"], a["playcount"]]
    end
    artists
  end

  def get_top_songs(username, time, api_key)
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopTracks&user=#{username}&period=#{time}&api_key=#{api_key}&format=json")).body)
    songs = []
    res["toptracks"]["track"].each do |t|
      songs << [t["name"], t["artist"]["name"], t["playcount"]]
    end
    songs
  end

  def get_top_albums(username, time, api_key)
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopAlbums&user=#{username}&period=#{time}&api_key=#{api_key}&format=json")).body)
    albums = []
    res["topalbums"]["album"].each do |a|
      albums << [a["name"], a["artist"]["name"], a["playcount"]]
    end
    albums
  end
end
