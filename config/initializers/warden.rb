# frozen_string_literal: true

::Rails.application.config.app_middleware.use ::Warden::Manager do |config|
  config.scope_defaults(
    :user,
    store: true,
    action: :unauthenticated_web,
    strategies: [:password]
  )

  config.scope_defaults(
    :api_v1,
    store: false,
    action: :unauthenticated_api,
    strategies: [:api_token]
  )

  config.failure_app = ->(env) do
    case env.dig('warden.options', :action)
    when :unauthenticated_web
      env['todo_bcdd'] = {unauthenticated: 'You need to sign in or sign up before continuing.'}

      ::Users::SessionsController.action(:new).call(env)
    when :unauthenticated_api
      [401, {'Content-Type' => 'application/json'}, ['{}']]
    else
      raise NotImplementedError
    end
  end
end

::Warden::Strategies.add(:password) do
  def valid?
    email, password = scoped_params.values_at('email', 'password')

    ::User::Email.new(email).valid? && ::User::Password.new(password).present?
  end

  def authenticate!
    email_and_password = scoped_params.slice('email', 'password')

    ::User::Authenticate::ByEmailAndPassword.call(email_and_password) do |on|
      on.failure { fail!('Incorrect email or password.') }
      on.success { |result| success!(result[:user]) }
    end
  end

  private

    def scoped_params
      @scoped_params ||= params.fetch('user', {})
    end
end

::Warden::Manager.serialize_into_session(:user, &:id)

::Warden::Manager.serialize_from_session(:user) do |id|
  ::User::FindById.call(id:) do |on|
    on.failure { raise NotImplementedError }
    on.success { |result| result[:user] }
  end
end

::Warden::Strategies.add(:api_token) do
  def valid?
    access_token.present?
  end

  def authenticate!
    ::User::Authenticate::ByAPIToken.call(token: access_token) do |on|
      on.success { |result| success!(result[:user]) }
      on.failure { fail!('Invalid access_token') }
    end
  end

  private

    def access_token
      @access_token ||= request.get_header('HTTP_X_ACCESS_TOKEN')
    end
end
