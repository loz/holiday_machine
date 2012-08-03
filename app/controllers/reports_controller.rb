class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authenticate_manager


  def index
  end

 end