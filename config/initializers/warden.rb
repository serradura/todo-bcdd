# frozen_string_literal: true

::Rails.application.config.app_middleware.use ::Warden::Manager do |config|
  config.default_scope = :user

  config.default_strategies(:password)

  config.failure_app = ->(env) { ::Users::SessionsController.action(:new).call(env) }
end

::Warden::Strategies.add(:password) do
  def valid?
    scoped_params = params[scope.to_s]

    scoped_params['email'] && scoped_params['password']
  end

  def authenticate!
    user = {id: 1}

    return success!(user) if user

    fail!('Invalid email or password')
  end
end

::Warden::Manager.serialize_into_session(:user) do |user|
  user[:id]
end

::Warden::Manager.serialize_from_session(:user) do |id|
  {id:}
end
