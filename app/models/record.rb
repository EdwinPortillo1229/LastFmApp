class Record < ApplicationRecord
  def get_all_songs(first_page)
    total_pages = first_page["recenttracks"]["@attr"]["totalPages"].to_i
    songs = first_page["recenttracks"]["track"].map{|track| track["name"]}
    songs
  end
end
