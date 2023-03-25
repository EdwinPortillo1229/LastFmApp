class Record < ApplicationRecord
  def get_all_songs(first_page)
    songs = {}
    total_pages = first_page["recenttracks"]["@attr"]["totalPages"].to_i
    songs = first_page["recenttracks"]["track"].map do |track|
      {
        "unaltered_name" => track["name"],
        "unaltered_artist" => track["artist"]["#text"],
        "unalter_album" => track["album"]["#text"],
        "name" =>  track["name"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
        "artist" => track["artist"]["#text"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
        "album" => track["album"]["#text"].gsub(/\s+/, "").gsub(/[^0-9a-z ]/i, '').downcase,
      }
    end
    songs
  end
end
