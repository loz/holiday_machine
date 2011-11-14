module VacationsHelper

  def create_holiday_row(holiday)
    content_tag_for :tr, holiday do
      content_tag(:td, holiday.date_from.strftime("%d/%m/%Y")) +
      content_tag(:td, holiday.date_to.strftime("%d/%m/%Y")) +
      content_tag(:td, holiday.description) +
      content_tag(:td, holiday.working_days_used) +
      content_tag(:td, holiday_status(holiday)) +
      content_tag(:td, link_to('Delete', vacation_path(holiday), :method => :delete, :confirm => 'Are you sure you want to delete this holiday request?', :remote => true))
    end
  end

  def holiday_status(holiday)
    status = holiday.holiday_status.status
    content_tag :span, status, :class => "label #{status.downcase}"
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


end
