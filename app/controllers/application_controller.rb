class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    include SessionsHelper

    def flash_msg(type, text)
        flash.now[type] ||= []
        flash.now[type] << text
    end

    def invalid_email_addr?(email)
        return false if /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i =~ email
        return true
    end
end
