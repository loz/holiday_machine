class UserDaysController < ApplicationController

  before_filter :authenticate_user!
  #TODO restrict to managers only

  # GET /user_days
  def index
    #The user viewing this is a manager and wants his own team
    @team_users = User.get_team_users(current_user.id)

    if params[:holiday_year_id]
      @selected_year = HolidayYear.find(params[:holiday_year_id])
    else
      @selected_year = HolidayYear.current_year
    end

    @user_day = UserDay.new

    respond_to do |format|
      format.js # index.js.erb
      format.html # index.html.erb
    end
end

  # GET /user_days/1
  def show
    @user_day = UserDay.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @user_day }
    end
  end

  # GET /user_days/new
  def new
    @user_day = UserDay.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @user_day }
    end
  end

  # GET /user_days/1/edit
  def edit
    @user_day = UserDay.find(params[:id])
  end

  # POST /user_days
  # POST /user_days.xml
  def create

    @user_day = UserDay.new(params[:user_day])
    @user_day.holiday_year = HolidayYear.current_year

    @user = @user_day.user
    @allowance = @user.get_holiday_allowance
    @allowance.days_remaining += @user_day.no_days

    respond_to do |format|
      if @user_day.save and @allowance.save
        flash[:success] = "This persons holiday allowance has been successfully updated."
        format.html { redirect_to(user_days_url) }
      else
        flash.now[:error] = "There was a problem updating this persons holiday allowance."
        format.html
      end
    end
  end

  # DELETE /user_days/1
  # DELETE /user_days/1.xml
  def destroy
    @user_day = UserDay.find(params[:id])
    @allowance = @user_day.user.get_holiday_allowance_for_dates(Date.today, Date.today)
    @allowance.days_remaining -= @user_day.no_days
    @user_day.destroy
    @allowance.save
    flash[:success] = "This persons extra days leave has been successfully deleted."
    respond_to do |format|
      format.html { redirect_to(user_days_url) }
      format.xml { head :ok }
    end
  end

end
