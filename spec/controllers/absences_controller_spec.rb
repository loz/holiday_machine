require 'spec_helper'

describe AbsencesController do

  before do
    @user = Factory.create(:user)
    @user.confirm!
    sign_in @user
  end

  describe "GET index" do
    it "assigns all absences as @absences" do
      get :index
      response.should be_success
    end

    it "has 25 days remaining since no holidays have been raised" do
      get :index
      assigns(:days_remaining).should == 25
    end

    it "should have less days remaining after taking a holiday" do
      pending "this test doesn't make sense"
      vacation = Factory.create(:vacation, :user=>@user)
      get :index
      assigns(:days_remaining).should == 16 #Just count the business days and deduct from 25
    end

    it "should raise an error if holiday days are only on a weekend" do
      pending "this is a model test?  for none existant factory?"
      vacation = Factory.build(:vacation, :user=>@user, :date_from => "20/08/2011", :date_to=> "21/08/2011")
      vacation.save
      vacation.errors { :working_days_used }.should include "This holiday request uses no working days"
    end

    it "should work as the holiday is within a holiday year" do
      pending "this too is not a controller test, what is it testing?"
      user_days_for_year = Factory.build(:user_days_for_year)
      days_remaining_before = user_days_for_year.days_remaining
      vacation = Factory.build(:vacation, :user=>@user, :date_from => "20/08/2011", :date_to=> "23/08/2011")
      vacation.user.stub(:get_holiday_allowance_for_dates).and_return(user_days_for_year)
      vacation.save
      vacation.errors.size.should == 0
      user_days_for_year.days_remaining.should < days_remaining_before
    end

  end

end
