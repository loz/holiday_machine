class ApplicationController < ActionController::Base
  protect_from_forgery

#  unless Rails.env="DEV"
#    rescue_from Exception, :with => :handler_exception
#  end

  #Devise override for home path
  def after_sign_in_path_for(resource)
    vacations_path
  end

  def handler_exception(exception)
     logger.error(" * Message   : #{exception.message}") unless exception.message.nil?
  end

end
