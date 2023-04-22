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

    if data.blank?
      redirect_to records_path and return
    end

    redirect_to record_path(@record, data_type: @record.data_type, data: data)
  end

  def show
    @record = Record.find(params[:id])
    @data_type = params[:data_type]
    @data = params[:data]
  end

  private
  def record_params
    params.require(:record).permit(:username, :months, :start_date, :data_type)
  end
end
