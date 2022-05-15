# frozen_string_literal: true

::Rails.application.config.app_middleware.use ::Warden::Manager do |config|
  config.default_scope = :user

  config.default_strategies(:password)

  config.failure_app = ->(env) { ::Users::SessionsController.action(:new).call(env) }
end

::Warden::Strategies.add(:password) do
  def valid?
    email, password = scoped_params&.values_at('email', 'password')

    email.present? && password.present? && ::URI::MailTo::EMAIL_REGEXP.match?(email)
  end

  def authenticate!
    email, password = scoped_params.fetch_values('email', 'password')

    user = ::User.find_by(email:)

    return success!(user) if user && ::BCrypt::Password.new(user.encrypted_password) == password

    fail!('Incorrect email or password.')
  end

  private

    def scoped_params
      @scoped_params ||= params[scope.to_s]
    end
end

::Warden::Manager.serialize_into_session(:user, &:id)

::Warden::Manager.serialize_from_session(:user) do |id|
  ::User.find_by(id:)
end
