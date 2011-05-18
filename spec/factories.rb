Factory.define :user do |u|
  u.forename { Factory.next(:forename) }
  u.surname { Factory.next(:surname) }
  u.email { Factory.next(:email) }
  u.password 'password'
  u.password_confirmation 'password'
  u.user_type_id 1
end

Factory.define :user_manager, :parent=>:user do |u|
  u.user_type_id 2
end

Factory.sequence :email do |n|
  "email#{n}@test.com"
end
Factory.sequence :forename do |n|
  "testforename#{n}"
end
Factory.sequence :surname do |n|
  "testsurname#{n}"
end

Factory.define :vacation do |v|
  v.date_from Date.today
  v.date_to Date.today+1.week
  v.holiday_status_id 1
  v.holiday_year_id  1
end