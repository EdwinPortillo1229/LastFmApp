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

end
