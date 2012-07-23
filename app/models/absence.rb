class Absence < ActiveRecord::Base

  HOL_COLOURS = %W{#FDF5D9 #D1EED1 #FDDFDE #DDF4Fb}
  BORDER_COLOURS = %W{#FCEEC1 #BFE7Bf #FBC7C6 #C6EDF9}
  
  belongs_to :holiday_status
  belongs_to :holiday_year
  belongs_to :user
  belongs_to :absence_type

  before_save :set_half_days, :set_working_days
  before_destroy :check_if_holiday_has_passed

  after_destroy :add_days_remaining
  after_create :decrease_days_remaining

  scope :team_holidays, lambda { |manager_id| where(:manager_id => manager_id) }
  scope :user_holidays, lambda { |user_id| where(:user_id => user_id).order('date_from ASC') }
  scope :per_holiday_year, lambda { |holiday_year_id| where(:holiday_year_id => holiday_year_id) }

  validates_presence_of :date_from
  validates_presence_of :date_to
  validates_presence_of :description

  validate :holiday_must_not_straddle_holiday_years
  validate :half_days_not_on_working_days, :on => :create
  validate :dont_exceed_days_remaining, :on => :create
  validate :date_from_must_be_before_date_to
  validate :working_days_greater_than_zero
  validate :no_overlapping_holidays, :on => :create

  attr_accessor :half_day_from, :half_day_to

  def date_from= val
    self[:date_from] = (convert_uk_date_to_iso val, true)
  end

  def date_to= val
    self[:date_to] = (convert_uk_date_to_iso val, false)
  end

  def self.team_holidays_as_json current_user, start_date, end_date

    #TODO filter this to show all hols, by team, and by user
    date_from = DateTime.parse(Time.at(start_date.to_i).to_s)
    date_to = DateTime.parse(Time.at(end_date.to_i).to_s)

    holidays = self.get_team_holidays_for_dates current_user, date_from, date_to
    bank_holidays = BankHoliday.where "date_of_hol between ? and ? ", date_from, date_to

    self.convert_to_json holidays, bank_holidays, current_user
  end


  def self.get_team_holidays_for_dates current_user, start_date, end_date
    #Allows everyone to see everyone's holidays
    team_users = User.all
    #TODO filter by team

    team_users_array = []
    team_users.each do |u|
      team_users_array << u.id
    end
    holidays = self.where "date_from >= ? and date_to <= ? and (user_id in(?))", start_date, end_date, team_users_array
    holidays
  end

  def self.mark_as_taken current_user
    holidays = self.where "date_to < ? and user_id =?", DateTime.now, current_user.id
    status_taken = HolidayStatus.find_by_status("Taken")
    status_authorised = HolidayStatus.find_by_status("Authorised")
    holidays.each do |hol|
      if hol.holiday_status == status_authorised
        exec_sql = ActiveRecord::Base.connection
        exec_sql.execute("UPDATE absences SET holiday_status_id = #{status_taken.id} WHERE absences.id = #{hol.id}")
      end
    end
  end

  private

  def half_days_not_on_working_days
   if date_on_non_working_day(date_from) && half_day_from != "Full Day"
     errors.add(:date_from, "- your half day falls on a non-working day")
     false
   elsif date_on_non_working_day(date_to) && half_day_to != "Full Day"
     errors.add(:date_to, "- your half day falls on a non-working day")   
     false
   end
  end

  def check_if_holiday_has_passed
    unless holiday_status_id == 1
      if date_to < Date.today
        errors.add(:base, "Holiday has passed")
        false
      end
    end
  end

  def self.convert_to_json(holidays, bank_holidays, current_user)
    json = []
    holidays.each do |hol|
      email = hol.user.email
      half_day_afternoon = hol.date_from.hour == 13 ? "Half Day PM" : ""
      half_day_morning = hol.date_to.hour == 12 ? "Half Day AM" : ""

      half_day = half_day_afternoon + half_day_morning
      unless half_day.blank?
        half_day = "\n"+half_day
      end

      if hol.user == current_user
        hol_hash = {:id => hol.id, :title => [hol.user.forename, hol.description].join(": ") + " " + half_day, :start => hol.date_from.iso8601, :end => hol.date_to.iso8601, :color => HOL_COLOURS[hol.holiday_status_id - 1], :textColor => '#404040', :borderColor => BORDER_COLOURS[hol.holiday_status_id - 1], :type => 'holiday'}
      else
        hol_hash = {:id => hol.id, :title=> hol.user.full_name + " " + half_day, :start => hol.date_from.iso8601, :end => hol.date_to.iso8601, :color => HOL_COLOURS[hol.holiday_status_id - 1], :textColor => '#404040', :borderColor => BORDER_COLOURS[hol.holiday_status_id - 1]}
      end
      json << hol_hash
    end

    bank_holidays.each do |hol|
      hol_hash = {:id => hol.id, :title => hol.name, :start => hol.date_of_hol.to_s, :color =>"black", :type => 'bank-holiday'}
      json << hol_hash
    end
    json
  end

  #TODO add the overlaps between team members
  #  def intra_team_holiday_clashes
  #  end

  def date_from_must_be_before_date_to
    errors.add(:date_from, " must be before date to.") if date_from > date_to
  end

  def working_days_greater_than_zero
    @working_days = business_days_between
    errors.add(:working_days_used, " - This holiday request uses no working days") if @working_days==0
  end


  def holiday_must_not_straddle_holiday_years
    number_years = HolidayYear.holiday_years_containing_holiday(date_from, date_to).count
    errors.add(:base, "Holiday must not cross years") if number_years> 1
  end

  def no_overlapping_holidays
    absences = Absence.find_all_by_user_id(self.user_id)
    absences.each do |absence|
      errors.add(:base, "Some leave already exists within this date range") if overlaps?(absence)
    end
  end

  def overlaps?(absence)
    (date_from.to_date - absence.date_to.to_date) * (absence.date_from.to_date - date_to.to_date) >= 0
  end

  def convert_uk_date_to_iso date_str, is_date_from
    split_date=date_str.split("/")
    if is_date_from
      DateTime.new(split_date[2].to_i, split_date[1].to_i, split_date[0].to_i, 9)
    else
      DateTime.new(split_date[2].to_i, split_date[1].to_i, split_date[0].to_i, 17)
    end
  end

  def set_working_days
    self[:working_days_used] = @working_days - half_day_adjustment

    unless self[:uuid]
      guid = UUID.new
      self[:uuid] = guid.generate
    end

    unless self[:holiday_year]
      self.holiday_year = HolidayYear.holiday_year_used(self[:date_from], self[:date_to]).first
    end

  end

  def business_days_between
    bank_holidays = BankHoliday.where("date_of_hol BETWEEN ? AND ?", date_from - 1.day, date_to + 1.day)
    holidays_array = bank_holidays.collect { |hol| hol.date_of_hol }
    weekdays = (date_from.to_date..date_to.to_date).reject { |d| [0, 6].include? d.wday or holidays_array.include?(d) }
    business_days = weekdays.length - half_day_adjustment
    debugger
    business_days = 0.5 if business_days == 1 && half_day_from == half_day_to 
    business_days
  end

  def decrease_days_remaining
    return unless self.absence_type_id == 1 #Only holidays affect the days remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    holiday_allowance.days_remaining -= business_days_between
    holiday_allowance.save
  end

  def add_days_remaining
    return unless self.absence_type_id == 1 #Only holidays affect the days remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    holiday_allowance.days_remaining += business_days_between
    holiday_allowance.save
  end

  def dont_exceed_days_remaining
    return unless self.absence_type_id == 1 #Only holidays affect the days remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    if holiday_allowance == 0 or holiday_allowance.nil? then
      return
    end
    debugger
    errors.add(:working_days_used, "-Number of days selected exceeds your allowance!") if holiday_allowance.days_remaining < business_days_between
  end

  def set_half_days
    if date_from.to_date == date_to.to_date
      #Ensure the half days match
      if (half_day_from != half_day_to) # && (half_day_from != "Full Day" || half_day_to != "Full Day")
        errors.add(:base, "Please ensure you select the same type of half day from both drop downs")
        return false
      else
        if half_day_from == "Half Day AM"
          #E.g 2011-01-01 09:00 to 2011-01-01 12:00
          write_attribute(:date_to, DateTime.new(date_to.year, date_to.month, date_to.day, 12))
        elsif half_day_from == "Half Day PM"
          #E.g 2011-01-01 13:00 to 2011-01-01 17:00
          write_attribute(:date_from, DateTime.new(date_to.year, date_to.month, date_to.day, 13))
        end
      end
    else
      if half_day_from != "Full Day" && half_day_from != "Half Day PM"
        errors.add(:base, "Leave can only begin with a half day in the afternoon, since this would mean you would be coming in on the afternoon of the first day of your leave")
        return false
      elsif half_day_to != "Full Day" && half_day_to != "Half Day AM"
        errors.add(:base, "A holiday cannot end with a half day in the afternoon, since you would be at work in the morning on the last day of your leave")
        return false
      else
        if half_day_from == "Half Day PM"
          #e.g 2011-01-01 13:00
          write_attribute(:date_from, DateTime.new(date_from.year, date_from.month, date_from.day, 13))
        end
        if half_day_to == "Half Day AM"
          #e.g 2011-05-01 12:00
          write_attribute(:date_to, DateTime.new(date_to.year, date_to.month, date_to.day, 12))
        end
      end
    end
  end

  def half_day_adjustment
    half_day_adjustment = 0.0
    if self.date_from.to_date == self.date_to.to_date
      if self.date_from.hour == 13 || self.date_to.hour == 12
        half_day_adjustment += 0.5
      end
    else
      #p "DateFrom hour", self.date_from.hour
      if self.date_from.hour == 13
        half_day_adjustment += 0.5
      end
      #p "Dateto hour", self.date_to.hour
      if self.date_to.hour == 12
        half_day_adjustment += 0.5
      end
    end
    half_day_adjustment
  end

  def date_on_non_working_day date_to_check
    return true if date_to_check.wday == 6 or date_to_check.wday == 0
    bank_holidays = BankHoliday.all
    return bank_holidays.collect{|hol| hol.date_of_hol}.include?(date_to_check.to_date)
  end

end
