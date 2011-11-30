HolidayStatus.create([{:status => 'Pending'}, {:status => 'Authorised'}, {:status => 'Cancelled'}, {:status => 'Taken'}])
UserType.create([{:name=>"Standard"}, {:name=>"Manager"}])

#2011 holidays
BankHoliday.create([{:name=>'New Years Day', :date_of_hol=>'2011-01-03'},
                    {:name=>'Good Friday', :date_of_hol=>'2011-04-22'},
                    {:name=>'Easter Monday', :date_of_hol=>'2011-04-25'},
                    {:name=>'Royal Wedding', :date_of_hol=>'2011-04-29'},
                    {:name=>'Early May Bank Holiday', :date_of_hol=>'2011-05-02'},
                    {:name=>'Spring Bank Holiday', :date_of_hol=>'2011-05-30'},
                    {:name=>'Summer Bank Holiday', :date_of_hol=>'2011-08-29'},
                    {:name=>'Christmas Day', :date_of_hol=>'2011-12-26'},
                    {:name=>'Boxing Day', :date_of_hol=>'2011-12-27'}])

#2012 holidays
BankHoliday.create([{:name=>'New Years Day', :date_of_hol=>'2012-01-02'},
                    {:name=>'Good Friday', :date_of_hol=>'2012-04-06'},
                    {:name=>'Easter Monday', :date_of_hol=>'2012-04-09'},
                    {:name=>'Early May Bank Holiday', :date_of_hol=>'2012-05-07'},
                    {:name=>'Spring Bank Holiday', :date_of_hol=>'2012-06-04'},
                    {:name=>'Diamond Jubilee', :date_of_hol=>'2012-06-05'},
                    {:name=>'Summer Bank Holiday', :date_of_hol=>'2012-08-27'},
                    {:name=>'Christmas Day', :date_of_hol=>'2012-12-25'},
                    {:name=>'Boxing Day', :date_of_hol=>'2012-12-26'}])

HolidayYear.create([{:description => "Oct 2010 to Sept 2011", :date_start => "2010-10-01", :date_end=> "2011-09-30"},
                    {:description => "Oct 2011 to Sept 2012", :date_start => "2011-10-01", :date_end=> "2012-09-30"},
                    {:description => "Oct 2012 to Sept 2013", :date_start => "2012-10-01", :date_end=> "2013-09-30"}])