#Factory.define :user do |u|
#  u.forename { Factory.next(:forename) }
#  u.surname { Factory.next(:surname) }
#  u.email { Factory.next(:email) }
#  u.password 'password'
#  u.password_confirmation 'password'
#  u.user_type_id 1
#end
#
#Factory.define :user_manager, :parent=>:user do |u|
#  u.user_type_id 2
#end
#
#Factory.sequence :email do |n|
#  "email#{n}@test.com"
#end
#Factory.sequence :forename do |n|
#  "testforename#{n}"
#end
#Factory.sequence :surname do |n|
#  "testsurname#{n}"
#end
#
#Factory.define :vacation do |v|
#  v.date_from Date.today
#  v.date_to Date.today+1.week
#  v.holiday_status_id 1
#  v.holiday_year_id  1
#end


FactoryGirl.define do
  factory :user do
    forename "Eamon"
    surname "Skelly"
    email "eamon_skelly@hotmail.com"
    password 'password'
    password_confirmation 'password'
    user_type_id 1
  end

  factory :vacation do
    #date_from Date.today
    #date_to Date.today+1.week
    date_from "14/08/2010"
    date_to "25/08/2010"
    holiday_status_id 1
    holiday_year_id 1
    description "1 weeks holiday"
  end

  factory :user_days_for_year do
    days_remaining 25
    holiday_year_id 1
    association :user, :factory => :user
  end
end