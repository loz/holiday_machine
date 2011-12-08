require 'spec_helper'

describe Vacation do

  describe "Create holidays" do

    before do
      @mgr1 = Factory(:user)
      @mgr2 = Factory(:user, :manager_id => @mgr1.id)
      @user1 = Factory(:user, :manager_id => @mgr1)
      @user2 = Factory(:user)
      @user3 = Factory(:user, :manager_id => @mgr2)
      @user4 = Factory(:user, :manager_id => @mgr1)

      #@vacation1 = Factory(:vacation, :user_id => @user1)
      #@vacation2 = Factory(:vacation, :user_id => @mgr2)
      #@vacation3 = Factory(:vacation, :user_id => @user2)
      #@vacation4 = Factory(:vacation, :user_id => @user3)
      #@vacation5 = Factory(:vacation, :user_id => @user4)
      #@vacation6 = Factory(:vacation, :user_id => @mgr1)
    end

    it "marks the correct number of days as taken for a holiday with two bank holidays" do
     user1 = Factory.create(:user)
     holiday = FactoryGirl.create(:vacation, :user_id=> user1.id, :date_from => "04/06/2012", :date_to => "08/06/2012")
     holiday.working_days_used.should == 3
    end

    it "raises validation exception when holiday is taken which is only on a bank holiday" do
     user = Factory.create(:user)
     expect{
     FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "04/06/2012", :date_to => "05/06/2012")
     }.to raise_exception(ActiveRecord::RecordInvalid)#, ["Working days used  - This holiday request uses no working days"]) 
    end

    it "uses the appropriate number of days around christmas" do
     user = Factory.create(:user)
     holiday =  FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "22/12/2011", :date_to => "02/01/2012")
     holiday.working_days_used.should == 5
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

  context "Holiday Status" do
    it "should mark holidays as taken if they are in the past and the existing status is authorised" do
      @user1 = Factory.stub(:user, :manager_id => @mgr1)
      holiday_status = stub_model(HolidayStatus, :status => "Authorised")
      vacation = Factory.stub(:vacation, :user_id => @user1.id, :holiday_status => holiday_status)
      vacations = []
      vacations << vacation
      Vacation.stub(:where).and_return(vacations)
      Vacation.mark_as_taken @user1
      vacation.reload
      vacation.holiday_status.should == HolidayStatus.find_by_status("Taken")
    end
    
    it "should not change the status if the holiday is not in the past" do
      @user1 = Factory.stub(:user, :manager_id => @mgr1)
      holiday_status = stub_model(HolidayStatus, :status => "Authorised")
      date_from = (DateTime.now + 1.month).strftime("%d/%m/%Y")
      date_to = (DateTime.now + 1.month + 4.days).strftime("%d/%m/%Y")
      vacation = Factory.stub(:vacation, :user_id => @user1.id, :date_from=> date_from, :date_to=> date_to, :holiday_status => holiday_status)
      vacations = []
      vacations << vacation
      Vacation.stub(:where).and_return(vacations)
      Vacation.mark_as_taken @user1
      vacation.holiday_status.should_not == HolidayStatus.find_by_status("Taken")
    end
    
    it "should not change the status of the holiday if the existing status is not authorised" do
      pending
    end
  end  

  context "Holiday does not straddle different year" do

    let(:user){FactoryGirl.create(:user)}
    
    it "should raise error if holiday crosses years" do
     expect{ 
     FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "28/09/2011", :date_to => "01/10/2011")
     }.to raise_exception(ActiveRecord::RecordInvalid) 
    end

    it "should not raise an error if the holiday is in one year" do
     holiday = FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "01/10/2011", :date_to => "03/10/2011")
     holiday.errors.should == {} 
    end
 
  end

  context "overlapping holidays" do
    
    let(:user){FactoryGirl.create(:user)}

    it "should fail if holidays overlap" do
     holiday1 = FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "01/10/2011", :date_to => "07/10/2011")
     holiday2 = FactoryGirl.build(:vacation, :user_id=> user.id, :date_from => "06/10/2011", :date_to => "16/10/2011")
     holiday2.errors[:base].first.should include("A holiday already exists within this date range")
    end
  
    it "should succeed if holidays do not overlap" do
     holiday1 = FactoryGirl.create(:vacation, :user_id=> user.id, :date_from => "01/10/2011", :date_to => "07/10/2011")
     holiday2 = FactoryGirl.build(:vacation, :user_id=> user.id, :date_from => "08/10/2011", :date_to => "16/10/2011")
     holiday2.errors[:base].should == [] 
    end
  end  

  context "Half Days" do

    let(:user){FactoryGirl.create(:user)}

    it "should raise error message when date from falls on non-working day" do
      vacation = FactoryGirl.build(:vacation, :user_id=> user.id, :date_from => "04/12/2011", :date_to => "07/12/2011", :half_day_from=> "Half Day PM")
      vacation.save
      vacation.errors[:date_from].first.should include('your half day falls on a non-working day')
    end

    it "should raise error message when date to falls on non-working day" do
      vacation = FactoryGirl.build(:vacation, :user_id=> user.id, :date_from => "05/12/2011", :date_to => "10/12/2011", :half_day_to=> "Half Day AM")
      vacation.save
      vacation.errors[:date_to].first.should include('your half day falls on a non-working day')
    end 
  
    it "should not allow a half day on a weekend" do
      subject.send(:date_on_non_working_day, Date.today.end_of_week).should == true 
    end

    it "should not allow a half day on a bank holiday" do
      subject.send(:date_on_non_working_day, Date.new(2012, 1, 2)).should == true
    end
   
    it "should allow a half day on a normal day" do
      subject.send(:date_on_non_working_day, Date.new(2011, 12, 7)).should == false
    end
  
  end

end
