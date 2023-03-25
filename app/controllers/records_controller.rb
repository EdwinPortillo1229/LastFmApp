class RecordsController < ApplicationController
  require 'net/http'

  LAST_FM_API_KEY = "11f12d6b2aae4b2b41e2abc116d687fd"

  def index
    @records = Record.all
  end

  def new
  end

  def create
    @record = Record.new(record_params.merge(:start_date => Date.today - (params[:record][:months]).to_i.months))
    @record.save!


    first_page = JSON.parse(Net::HTTP.get_response(URI("https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{@record.username}&page=1&limit=200&from=#{(@record.created_at - @record.months.months).utc}&to=#{@record.created_at.utc}&api_key=#{LAST_FM_API_KEY}&format=json")).body)
    songs = @record.get_all_songs(first_page, @record.username, (@record.created_at - @record.months.months).utc, @record.created_at.utc, LAST_FM_API_KEY)
    debugger

    redirect_to record_path(@record, songs: songs)
  end

  def show
    @record = Record.find(params[:id])
    @songs = params[:songs]
  end

  private
  def record_params
    params.require(:record).permit(:username, :months, :start_date, :data_type)
  end
end
