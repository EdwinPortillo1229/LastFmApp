class RecordsController < ApplicationController
  require 'net/http'

  LAST_FM_API_KEY = "11f12d6b2aae4b2b41e2abc116d687fd"

  def new
    Record.destroy_all
  end

  def create
    start_date = Record.get_start_date(params)
    # @record = Record.new(record_params.merge(:start_date => start_date))
    # @record.save!

    data = Record.get_lastfm_data(params)

    if data.blank?
      redirect_to root_path, notice: "No Last.Fm users with the usersname '#{params[:record][:username]}' were found, please try again." and return
      @record.destroy!
    end

    redirect_to collage_path(data: data)
  end

  def collage
    @end_string = "for #{params[:data][:username]} from #{params[:data][:start_date].to_date.to_formatted_s(:long_ordinal)} until now"
    @data = params[:data][:random_string]
    puts("data: #{@data}")
    render template: "records/albums"
  end

  private
  def record_params
    params.require(:record).permit(:username, :months, :start_date, :data_type)
  end
end
