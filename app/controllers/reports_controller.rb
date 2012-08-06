class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_manager

  def index
  	@current_year_id = HolidayYear.current_year.id
  	@users = current_user.all_staff
  end

 end