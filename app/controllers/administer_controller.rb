class AdministerController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_manager

  def index
    #TODO restrict holidays by year
    @statuses = HolidayStatus.all
    @users = current_user.all_staff.includes(:absences)
    @users = User.get_team_users(current_user.id).includes(:absences)
    respond_to do |format|
       format.html
    end
  end

end
