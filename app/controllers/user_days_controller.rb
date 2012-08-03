class UserDaysController < ApplicationController

  before_filter :authenticate_user!
  #TODO restrict to managers only

  # GET /user_days
  def index
    #The user viewing this is a manager and wants his own team
    @team_users = User.get_team_users(current_user.id)

    if params[:holiday_year_id]
      @selected_year = HolidayYear.find(params[:holiday_year_id])
     elsif flash[:holiday_year_id]
      @selected_year = HolidayYear.find(flash[:holiday_year_id])
    else
      @selected_year = HolidayYear.current_year
    end

    @user_day = UserDay.new

    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /user_days
  # POST /user_days.xml
  def create
    @user_day = UserDay.new(params[:user_day])

    if params[:user_day][:holiday_year_id]
      @user_day.holiday_year = HolidayYear.find(params[:user_day][:holiday_year_id])
    else
      @user_day.holiday_year = HolidayYear.current_year
    end

    holiday_year_id = @user_day.holiday_year.id

    @user = @user_day.user
    @allowance = @user.get_holiday_allowance_for_selected_year(@user_day.holiday_year)
    @allowance.days_remaining += @user_day.no_days

    respond_to do |format|
      if @user_day.save and @allowance.save
        flash[:success] = "This persons holiday allowance has been successfully updated."
        format.html { redirect_to user_days_url, :flash => { :holiday_year_id => holiday_year_id } }
      else
        flash.now[:error] = "There was a problem updating this persons holiday allowance."
        #TODO below prevents error, but loses the validation messages
        format.html { redirect_to user_days_url, :flash => { :holiday_year_id => holiday_year_id } }
      end
    end
  end

end
