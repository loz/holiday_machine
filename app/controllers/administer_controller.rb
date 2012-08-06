class AdministerController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_manager

  def index
    #TODO restrict holidays by year
    @statuses = HolidayStatus.all
    # @users = current_user.all_staff.includes(:absences).where('absences.holiday_year_id = ?', HolidayYear.current_year.id)
    @users = User.get_team_users(current_user.id).includes(:absences).where('absences.holiday_year_id = ?', HolidayYear.current_year.id)
    respond_to do |format|
      format.html
    end
  end

end
