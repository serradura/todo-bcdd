# frozen_string_literal: true

module Users
  class RegistrationsController < BaseController
    def new
      render_sign_up
    end

    def create
      user_params = params.require(:user)

      input = {
        email: user_params[:email],
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation]
      }

      ::User::RegisterAndSendWelcomeEmail
        .call(input)
        .on_failure(:validation_errors) { |result| render_sign_up_with_form_errors(result) }
        .on_success do |result|
          warden.set_user(result[:user], scope: :user)

          notice = 'Congratulations, your account has been successfully created.'

          redirect_to(users_root_url, notice:)
        end
    end

    private

      def render_sign_up(email: nil, errors: nil)
        render('users/registrations/new', locals: {
          user_email: email,
          form_errors: errors
        })
      end

      def render_sign_up_with_form_errors(result)
        render_sign_up(email: result[:email], errors: result[:errors])
      end
  end
end
