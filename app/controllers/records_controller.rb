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


    songs = @record.get_top_songs(@record.username, @record.months, LAST_FM_API_KEY)
    artists = @record.get_top_artists(@record.username, @record.months, LAST_FM_API_KEY)
    albums = @record.get_top_albums(@record.username, @record.months, LAST_FM_API_KEY)

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
