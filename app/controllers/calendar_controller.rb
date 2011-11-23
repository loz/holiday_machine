class CalendarController < ApplicationController

  before_filter :authenticate_user!

  def index
    #Populate the calendar
    respond_to do |format|
      format.json {
        holidays_json = Vacation.team_holidays_as_json current_user, params[:start], params[:end]
        render :json => holidays_json
      }
    end
  end

  def show
    @holiday_status = HolidayStatus.order(:status)
  end

end
