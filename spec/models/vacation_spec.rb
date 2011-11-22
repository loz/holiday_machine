require 'spec_helper'

describe Vacation do

#  before do
#    @vacation = Vacation.new
#  end

  describe "Create holidays" do

    before do
      @mgr1 = Factory(:user)
      @mgr2 = Factory(:user, :manager_id => @mgr1.id)
      @user1 = Factory(:user, :manager_id => @mgr1)
      @user2 = Factory(:user)
      @user3 = Factory(:user, :manager_id => @mgr2)
      @user4 = Factory(:user, :manager_id => @mgr1)

      @vacation1 = Factory(:vacation, :user_id => @user1)
      @vacation2 = Factory(:vacation, :user_id => @mgr2)
      @vacation3 = Factory(:vacation, :user_id => @user2)
      @vacation4 = Factory(:vacation, :user_id => @user3)
      @vacation5 = Factory(:vacation, :user_id => @user4)
      @vacation6 = Factory(:vacation, :user_id => @mgr1)

    end

    it "retrieves the correct holidays for my team within specific dates" do
      pending
      vacations = Vacation.get_team_holidays_for_dates @user1, Date.today-1.month, Date.today+1.month
      y vacations
    end

    it "should return the appropriate no of users" do
      pending
      p @user4.id
      p @user.manager_id
      users = User.where("(id = ? OR manager_id = ?) AND confirmed_at is not null", @user4.id, @user4.manager_id)
    end


  end

  it "should raise error if holiday has passed unless pending"

  it "should ensure date from must be before date to" do
    pending
    @vacation.date_from = "2011-02-01"
    @vacation.date_to = "2011-02-01"
  end


end
