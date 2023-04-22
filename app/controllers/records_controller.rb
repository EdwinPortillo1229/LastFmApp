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

    data = @record.get_lastfm_data
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
