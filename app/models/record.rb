require 'rmagick'
require 'securerandom'
class Record < ApplicationRecord
  def self.get_lastfm_data(params)
    if params[:record][:username].blank? || params[:record][:months].blank? || params[:record][:data_type].blank?
      return nil
    end
    return nil if !["7day", "1month", "3month", "6month", "12month"].include?(params[:record][:months])
    return nil if !["3x3", "4x4", "5x5"].include?(params[:record][:data_type])

    username = params[:record][:username]
    months = params[:record][:months]
    data_type = params[:record][:data_type]
    start_date = Record.get_start_date(params)

    user_data = (Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopAlbums&user=poop&period=#{months}&api_key=#{RecordsController::LAST_FM_API_KEY}&format=json")))
    if user_data.code == "404"
      return nil
    end

    res = JSON.parse(user_data.body)

    case data_type
    when "3x3"
      total_records = 9
      canvas_width = 900
      canvas_height = 900
      image_width = 300
      image_height = 300
      columns = 3
    when "4x4"
      total_records = 16
      canvas_width = 1200
      canvas_height = 1200
      image_width = 300
      image_height = 300
      columns = 4
    when "5x5"
      total_records = 25
      canvas_width = 1500
      canvas_height = 1500
      image_width = 300
      image_height = 300
      columns = 5
    end

    image_paths = []
    random_string = SecureRandom.random_number(1_000_000_000).to_s.rjust(10, '0')

    res["topalbums"]["album"].first(total_records).each do |a|
      images_array = a["image"]
      extra_large_image_url = images_array[3]["#text"]
      image_paths << extra_large_image_url
    end
    canvas = Magick::Image.new(canvas_width, canvas_width) do |c|
      c.background_color = 'white'
    end

    image_paths.each_with_index do |image_url, index|
      image = Magick::Image.read(image_url).first
      image.resize_to_fill!(image_width, image_height)
      row = index / columns
      col = index % columns
      canvas.composite!(image, col * image_width, row * image_height, Magick::OverCompositeOp)
    end

    canvas.write(Rails.root.join('public', 'collages', "output_collage#{random_string}.jpg"))
    {random_string: random_string, start_date: start_date, username: username}
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
    random_string = SecureRandom.random_number(1_000_000_000).to_s.rjust(10, '0')

    res["topalbums"]["album"].first(20).each do |a|
      images_array = a["image"]
      extra_large_image_url = images_array[3]["#text"]
      image_paths << extra_large_image_url
      albums << {album_name: a["name"], artist_name: a["artist"]["name"], playcount: a["playcount"], image: extra_large_image_url}
    end
    canvas = Magick::Image.new(900, 900) do |c|
      c.background_color = 'white'
    end

    canvas_width = 900
    canvas_height = 900
    image_width = 300
    image_height = 300
    columns = 3

    canvas = Magick::Image.new(canvas_width, canvas_height) do |c|
      c.background_color = 'white'
    end

    image_paths.first(9).each_with_index do |image_url, index|
      image = Magick::Image.read(image_url).first
      image.resize_to_fill!(image_width, image_height)
      row = index / columns
      col = index % columns
      canvas.composite!(image, col * image_width, row * image_height, Magick::OverCompositeOp)
    end

    canvas.write(Rails.root.join('public', 'collages', "output_collage#{random_string}.jpg"))
    random_string
  end
end
