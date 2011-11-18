module UserDaysHelper

  def calendar_year(holiday_year)
    [holiday_year.date_start, holiday_year.date_end].map do |d|
      ordinalize_date(d)
    end.join(' - ')
  end

  def ordinalize_date(date)
    date.strftime("#{date.day.ordinalize} %B %Y")
  end

end
