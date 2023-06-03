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

    user_data = (Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getTopAlbums&user=#{username}&period=#{months}&api_key=#{RecordsController::LAST_FM_API_KEY}&format=json")))
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

    image_paths.reject!(&:empty?)

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
end
