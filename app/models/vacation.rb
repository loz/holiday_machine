class Vacation < ActiveRecord::Base

  HOL_COLOURS = %W{#FDF5D9 #D1EED1 #FDDFDE #DDF4Fb}
  BORDER_COLOURS = %W{#FCEEC1 #BFE7Bf #FBC7C6 #C6EDF9}

  #TODO remove the manager_id from this class, get it via the user - so that if the manager is updated, there won't be a problem

  belongs_to :holiday_status
  belongs_to :holiday_year
  belongs_to :user

  before_save :save_working_days
  before_destroy :check_if_holiday_has_passed

  after_destroy :add_days_remaining
  after_create :decrease_days_remaining

  scope :team_holidays, lambda { |manager_id| where(:manager_id => manager_id) }
  scope :user_holidays, lambda { |user_id| where(:user_id => user_id) }
  scope :per_holiday_year, lambda { |holiday_year_id| where(:holiday_year_id => holiday_year_id) }

  validates_presence_of :date_from
  validates_presence_of :date_to
  validates_presence_of :description

  validate :holiday_must_not_straddle_holiday_years

  validate :dont_exceed_days_remaining, :on => :create
  validate :date_from_must_be_before_date_to
  validate :working_days_greater_than_zero
  validate :no_overlapping_holidays, :on => :create

  def date_from= val
    self[:date_from] = convert_uk_date_to_iso val
  end

  def date_to= val
    self[:date_to] = convert_uk_date_to_iso val
  end

  def self.team_holidays_as_json current_user, start_date, end_date
    #TODO filter this to show all hols, by team, and by user
    date_from = Time.at(start_date.to_i).to_date
    date_to = Time.at(end_date.to_i).to_date

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

  private

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
      if hol.user == current_user
        hol_hash = { :id => hol.id, :title => [hol.user.forename, hol.description].join(": "), :start => hol.date_from.to_s, :end => hol.date_to.to_s, :color => HOL_COLOURS[hol.holiday_status_id - 1], :textColor => '#404040', :borderColor => BORDER_COLOURS[hol.holiday_status_id - 1], :type => 'holiday' }
      else
        hol_hash = { :id => hol.id, :title=> hol.user.full_name, :start => hol.date_from.to_s, :end => hol.date_to.to_s, :color => HOL_COLOURS[hol.holiday_status_id - 1], :textColor => '#404040', :borderColor => BORDER_COLOURS[hol.holiday_status_id - 1] }
      end
      json << hol_hash
    end

    bank_holidays.each do |hol|
      hol_hash = { :id => hol.id, :title => hol.name, :start => hol.date_of_hol.to_s, :color =>"black", :type => 'bank-holiday' }
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
    #TODO this query will not be right - test with sql
    number_years = HolidayYear.holiday_years_containing_holiday(date_from, date_to).count
    errors.add(:base, "Holiday must not cross years") if number_years> 1
  end

  def no_overlapping_holidays
    holidays = Vacation.find_all_by_user_id(self.user_id)
    holidays.each do |holiday|
      errors.add(:base, "A holiday already exists within this date range") if overlaps?(holiday)
    end
  end

  def overlaps?(holiday)
    (date_from - holiday.date_to) * (holiday.date_from - date_to) >= 0
  end

  def convert_uk_date_to_iso date_str
    split_date=date_str.split("/")
    Date.new(split_date[2].to_i, split_date[1].to_i, split_date[0].to_i)
  end

  def save_working_days #TODO rename method
    self[:working_days_used] = @working_days

    unless self[:uuid]
      guid = UUID.new
      self[:uuid] = guid.generate
    end

    unless self[:holiday_year]
      self.holiday_year = HolidayYear.holiday_year_used(self[:date_from], self[:date_to]).first
    end

  end

  def business_days_between
    holidays = BankHoliday.where("date_of_hol BETWEEN ? AND ?", date_from, date_to)
    holidays_array = holidays.collect { |hol| hol.date_of_hol }
    weekdays = (date_from..date_to).reject { |d| [0, 6].include? d.wday or holidays_array.include?(d) }
    business_days = weekdays.length
  end

  def decrease_days_remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    holiday_allowance.days_remaining -= business_days_between
    holiday_allowance.save
  end

  def add_days_remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    holiday_allowance.days_remaining += business_days_between
    holiday_allowance.save
  end

  def dont_exceed_days_remaining
    holiday_allowance = self.user.get_holiday_allowance_for_dates self.date_from, self.date_to
    if holiday_allowance == 0 or holiday_allowance.nil? then
      return
    end
    errors.add(:working_days_used, "-Number of days selected exceeds your allowance!") if holiday_allowance.days_remaining < business_days_between
  end

end
