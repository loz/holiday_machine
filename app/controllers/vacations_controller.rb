class VacationsController < ApplicationController

  before_filter :authenticate_user!

  # GET /vacations
  def index
    @vacations ||= []

    @vacation = Vacation.new
    @vacation.holiday_year_id = HolidayYear.current_year.id

    @holiday_statuses = HolidayStatus.pending_only

    if params[:holiday_year_id]
      user_days_per_year = UserDaysForYear.where(:user_id=> current_user.id, :holiday_year_id=>params[:holiday_year_id]).first
      @days_remaining = user_days_per_year.days_remaining
      @vacations = Vacation.user_holidays(current_user.id).per_holiday_year(params[:holiday_year_id])
    else
      @days_remaining = current_user.get_holiday_allowance.days_remaining
      @vacations = Vacation.user_holidays current_user.id
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /vacations/1
  def show
    @vacation = Vacation.find(params[:id])

    respond_to do |format|
      format.html
      format.json
    end
  end


  # POST /vacations
  # POST /vacations.xml
  def create
    @vacation = Vacation.new(params[:vacation])
    @vacation.holiday_year_id = nil #THIS MUST BE REMOVED OR WILL BE PASSED FROM THE FILTER
    @vacation.user = current_user
    @vacation.holiday_status_id = 1
    manager_id = current_user.manager_id
    #@vacation.manager_id = manager_id # Add manager to all holidays
    manager = User.find_by_id(manager_id)

    respond_to do |format|
      if @vacation.save
        unless manager.nil?
          HolidayMailer.holiday_request(current_user, manager, @vacation).deliver
        end

        user_days_per_year = UserDaysForYear.where(:user_id=> current_user.id, :holiday_year_id => params[:vacation][:holiday_year_id]).first
        @days_remaining = user_days_per_year.days_remaining

        flash.now[:success] = "Successfully created holiday."
        format.js
      else
        flash.now[:error] = "There was a problem creating your holiday request"
        format.js
      end
    end
  end

  def update
    @vacation = Vacation.find_by_id(params[:id])
    @vacation.notes = params[:vacation][:notes]
    @vacation.holiday_status_id = params[:vacation][:holiday_status_id]
    @vacation.save
    vacation_user = @vacation.user
    if vacation_user.manager_id
      manager = User.find_by_id(vacation_user.manager_id)
      #TODO prevent holiday status being switched to pending
      HolidayMailer.holiday_actioned(manager, @vacation).deliver
    end

    respond_to do |format|
      flash[:notice] = "Holiday status has been changed"
      format.js
    end

  end


  # DELETE /vacations/1
  # DELETE /vacations/1.xml
  def destroy
    @vacation = Vacation.find(params[:id])
    respond_to do |format|
      if @vacation.destroy
        unless current_user.manager_id.nil?
          manager = User.find_by_id(@vacation.manager_id)
          HolidayMailer.holiday_cancellation(current_user, manager, @vacation).deliver
        end
        @days_remaining = current_user.get_holiday_allowance.days_remaining
        @row_id = params[:id]
        @failed = false
        flash.now[:success] = "Holiday deleted"
        format.js
      else
        flash[:error] = "Could not delete a holiday which has passed"
        @failed = true
        format.js
      end
    end
  end

end
