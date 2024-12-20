class RecordsController < ApplicationController
  require 'net/http'

  LAST_FM_API_KEY = ENV['LAST_FM_API_KEY']
     
  def new
    Record.destroy_all
  end

  def create
    start_date = Record.get_start_date(params)
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
end
