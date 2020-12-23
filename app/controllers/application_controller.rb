# frozen_string_literal: true

# Abstract class for centralizing ActionController customization
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize, :customize_views

  def authorize
    deployment_finished = helpers.deployment_finished_checks
    active_session = helpers.active_session?
    @active_session_ip = KeyValue.get(:active_session_ip) unless active_session || deployment_finished
    return if helpers.check_and_alert(request.path)

    if deployment_finished
      redirect_to(wrapup_path)
    else
      redirect_to(welcome_path)
    end
  end

  def customize_views
    return unless Rails.configuration.x.override_views

    prepend_view_path(Rails.root.join('vendor', 'views'))
  end
end
