require 'rmagick'
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
      self.get_top_songs
    end

    data
  end

  def self.get_start_date(params)
    (params[:record][:months] == "7day") ? (Date.today - 7.days) : (Date.today - (params[:record][:months]).to_i.months)
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

  def get_top_artists
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopArtists&user=#{self.username}&period=#{self.months}&api_key=#{RecordsController::LAST_FM_API_KEY}&format=json")).body)
    artists = []
    res["topartists"]["artist"].first(20).each do |a|
      images_array = a["image"]
      extra_large_image_url = images_array[3]["#text"]
      artists << {name: a["name"], playcount: a["playcount"], image: extra_large_image_url}
    end
    artists
  end

  def get_top_songs
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopTracks&user=#{self.username}&period=#{self.months}&api_key=#{RecordsController::LAST_FM_API_KEY}&format=json")).body)
    songs = []
    res["toptracks"]["track"].each do |t|
      songs << {song_name: t["name"], artist_name: t["artist"]["name"], playcount: t["playcount"]}
    end
    songs
  end

  def get_top_albums
    res = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopAlbums&user=#{self.username}&period=#{self.months}&api_key=#{RecordsController::LAST_FM_API_KEY}&format=json")).body)
    albums = []
    image_paths = []
    res["topalbums"]["album"].first(20).each do |a|
      images_array = a["image"]
      extra_large_image_url = images_array[3]["#text"]
      image_paths << extra_large_image_url
      albums << {album_name: a["name"], artist_name: a["artist"]["name"], playcount: a["playcount"], image: extra_large_image_url}
    end
    canvas = Magick::Image.new(900, 900) do |c|
      c.background_color = 'white'
    end

    image_paths.each_with_index do |image_path, index|
      image = Magick::Image.read(image_path).first
      image.resize_to_fill!(image_width, image_height)
      row = index / 3
      col = index % 3
      canvas.composite!(image, col * image_width, row * image_height, Magick::OverCompositeOp)
    end

    canvas.write('path/to/output_collage.jpg')
    debugger
    albums
  end
end
