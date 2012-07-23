module UserDaysHelper

  def calendar_year(holiday_year)
    [holiday_year.date_start, holiday_year.date_end].map do |d|
      ordinalize_date(d)
    end.join(' - ')
  end

  def ordinalize_date(date)
    date.strftime("#{date.day.ordinalize} %B %Y")
  end

  def overall_days_for_year user, selected_year
    absences = Absence.where("holiday_year_id = ? AND user_id = ? and absence_type_id =1", selected_year.id, user.id)
    hols_used = absences.blank? ? 0 : absences.sum(:working_days_used)
    days_remaining = days_remaining user, selected_year
    hols_used + days_remaining
  end

  def days_remaining user, selected_year
    user.get_holiday_allowance_for_selected_year(selected_year).days_remaining
  end

end
