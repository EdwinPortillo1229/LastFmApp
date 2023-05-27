class RecordsController < ApplicationController
  require 'net/http'

  LAST_FM_API_KEY = "11f12d6b2aae4b2b41e2abc116d687fd"

  def new
    Record.destroy_all
  end

  def create
    start_date = Record.get_start_date(params)
    @record = Record.new(record_params.merge(:start_date => start_date))
    @record.save!

    data = @record.get_lastfm_data

    if data.blank?
      redirect_to root_path, notice: "No Last.Fm users with the usersname '#{@record.username}' were found, please try again" and return
      @record.destroy!
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
