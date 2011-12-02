module VacationsHelper

  def create_holiday_row(holiday)
    content_tag_for :tr, holiday do
      content_tag(:td, show_date_with_details(holiday)) +
          content_tag(:td, show_date_with_details(holiday, false)) +
          content_tag(:td, holiday.description) +
          content_tag(:td, holiday.working_days_used) +
          content_tag(:td, holiday_status(holiday)) +
          content_tag(:td, :class => "actions") do
            link_to('View', vacation_path(holiday)) +
                link_to('Delete', vacation_path(holiday), :method => :delete, :confirm => 'Are you sure you want to delete this holiday request?', :remote => true)
          end
    end
  end

  def holiday_status(holiday)
    status = holiday.holiday_status.status
    content_tag :span, status, :class => holiday_status_class(holiday)
  end

  def holiday_status_class(holiday)
    "label #{holiday.holiday_status.status.downcase}"
  end

  private

  def day_to_show
    day_show = ""
    if @week==1 then
      if @day>@start_day-1 then
        day_show = (@day-@start_day+1).to_s
      end
    else
      if @day_adjusted-@start_day+1<@days_in_month+@start_day
        day_show =(@day-@start_day+1).to_s
      end
    end
    day_show
  end

  def days_in_month date_to_check
    days_in_month = (((date_to_check+1.month).at_beginning_of_month)-1.day).mday
    days_in_month
  end


  def show_date_with_details hol, is_date_from = true

    date_from = hol.date_from
    date_to = hol.date_to

    if is_date_from
      if date_from.hour == 13
        date_from.strftime("%d/%m/%Y")
      else
        date_from.strftime("%d/%m/%Y") + " - Half Day PM"
      end
    else
      if date_to.hour == 12
        date_to.strftime("%d/%m/%Y")
      else
        date_to.strftime("%d/%m/%Y") + " - Half Day AM"
      end
    end

  end

end
