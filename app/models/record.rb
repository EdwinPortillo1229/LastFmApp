class Record < ApplicationRecord
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
  end

  def get_top_songs(username, time, api_key)
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopTracks&user=#{username}&period=#{time}&api_key=#{api_key}&format=json")).body)
  end

  def get_top_albums(username, time, api_key)
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopAlbums&user=#{username}&period=#{time}&api_key=#{api_key}&format=json")).body)
  end
end
