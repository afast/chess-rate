class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :detect_language

  def detect_language
    I18n.locale = :es
  end
end
