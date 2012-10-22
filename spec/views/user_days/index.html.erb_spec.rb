require 'spec_helper'

describe "user_days/index.html.erb" do
  before(:each) do
    assign(:selected_year, stub(:Year, :id => 123))
    assign(:team_users, []) #should be some users
  end

  it "renders a list of user_days" do
    render
  end
end
