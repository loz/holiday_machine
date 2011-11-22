FactoryGirl.define do
  factory :user do
    forename "Eamon"
    surname "Skelly"
    sequence(:email) {|n| "person#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    user_type_id 1
    invite_code "Sage1nvite00"
  end

  factory :vacation do
    #date_from Date.today
    #date_to Date.today+1.week
    date_from "14/08/2011"
    date_to "25/08/2011"
    holiday_status_id 1
    holiday_year_id 1
    description "1 weeks holiday"
  end

  factory :user_days_for_year do
    days_remaining 25
    holiday_year_id 1
    association :user, :factory => :user
  end

  factory :holiday_year do
    date_start "2011-10-01"
    date_end "2012-09-30"
    description "test year"
  end

end