require 'digest/md5'

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
      link_to('&#215;'.html_safe, '#', :class => 'close') +
      content_tag(:p, flash_message)
    end
  end

  def render_flash_messages
    arr = []
    flash.each do |flash_type, flash_message|
      mssg = content_tag :div, :class => "alert-message #{flash_type}" do
        link_to('&#215;'.html_safe, '#', :class => 'close') +
        content_tag(:p, flash_message)
      end
      arr << mssg
    end
    arr.join.html_safe
  end

  def gravatar(user, options = {})
    options = { :size => 75, :default => 'identicon'}.merge(options)
    email_address = user.email.downcase
    hash = Digest::MD5.hexdigest(email_address)
    image_src = "http://www.gravatar.com/avatar/#{hash}"
    query_string = options.map {|key, value| "#{key}=#{value}"}
    image_src << "?" << query_string.join("&")
    image_src
  end

  def body_classes
    arr = [params[:controller], params[:action]]
    arr << 'no-sidebar' unless content_for?(:sidebar)

    arr.join(' ')
  end

end
