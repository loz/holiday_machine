class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_manager


  def index
  	@absences = Absence.includes(:user).order('users.email ASC').all
  end

 end