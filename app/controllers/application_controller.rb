class ApplicationController < ActionController::Base
  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    locale_avaiable = I18n.available_locales.include?(locale)
    I18n.locale = locale_avaiable ? locale : I18n.default_locale
  end

  private

  before_action :set_locale

  def default_url_options
    {locale: I18n.locale}
  end

  def find_object model, id
    model.find(id)
  rescue StandardError
    render file: Rails.root.to_s << ("/public/404.html")
  end
end
