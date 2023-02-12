class RecordsController < ApplicationController
  def index
    @records = Record.all
  end

  def new
  end

  def create
    @record = Record.new(record_params.merge(:start_date => Date.today - (params[:record][:months]).to_i.months))
    @record.save!
    redirect_to @record
  end

  def show
    @record = Record.find(params[:id])
  end

  private
  def record_params
    params.require(:record).permit(:username, :months, :start_date, :data_type)
  end
end
