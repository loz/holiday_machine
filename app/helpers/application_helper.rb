module ApplicationHelper

  def show_errors_as_list(errors)
    content_tag(:ul) do
      errors.full_messages.map do |mssg|
        content_tag(:li, mssg)
      end.join.html_safe
    end
  end

  def show_flash(flash_type, flash_message)
    content_tag :div, :class => "alert-message #{flash_type}" do
      link_to('x', '#', :class => 'close') +
      content_tag(:p, flash_message)
    end
  end

  def render_flash_messages
    arr = []
    flash.each do |flash_type, flash_message|
      mssg = content_tag :div, :class => "alert-message #{flash_type}" do
        link_to('×', '#', :class => 'close') +
        content_tag(:p, flash_message)
      end
      arr << mssg
    end
    arr.join.html_safe
  end
end
