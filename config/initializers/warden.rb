# frozen_string_literal: true

::Rails.application.config.app_middleware.use ::Warden::Manager do |config|
  config.default_scope = :user

  config.default_strategies(:password)

  config.failure_app = ->(env) { ::Users::SessionsController.action(:new).call(env) }
end

::Warden::Strategies.add(:password) do
  def valid?
    email_and_password = scoped_params.slice('email', 'password')

    ::User::ValidateEmailAndPassword.call(email_and_password).success?
  end

  def authenticate!
    email_and_password = scoped_params.slice('email', 'password')

    ::User::Authenticate.call(email_and_password) do |on|
      on.failure { fail!('Incorrect email or password.') }
      on.success { |result| success!(result[:user]) }
    end
  end

  private

    def scoped_params
      @scoped_params ||= params[scope.to_s]
    end
end

::Warden::Manager.serialize_into_session(:user, &:id)

::Warden::Manager.serialize_from_session(:user) do |id|
  ::User::Find.call(id:) do |on|
    on.failure { raise NotImplementedError }
    on.success { |result| result[:user] }
  end
end
