# frozen_string_literal: true

module Users
  class PasswordsController < BaseController
    def new
      render('users/passwords/new')
    end

    def create
      email = params.require(:user).fetch(:email)

      ::User::Password::Reset::SendInstructions.call(email:)

      notice = 'You will receive an email with instructions for how to confirm your email address in a few minutes.'

      redirect_to(root_path, notice:)
    end

    def edit
      reset_password_token = params[:uuid]

      ::User::Password::Reset::ValidateToken
        .call(token: reset_password_token)
        .on_success { render_edit(reset_password_token:, errors: nil) }
        .on_failure do
          notice =
            "You can't access this page without coming from a password reset email. " \
            'If you do come from a password reset email, please make sure you used the full URL provided.'

          redirect_to(root_path, notice:)
        end
    end

    def update
      user_params = params.require(:user)

      reset_password_token = params[:uuid]

      input = {
        token: reset_password_token,
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation]
      }

      ::User::Password::Reset
        .call(input)
        .on_failure(:invalid_token) { forbid_access_and_redirect }
        .on_failure(:user_not_found) { forbid_access_and_redirect }
        .on_failure(:invalid_password) { |result| render_edit(reset_password_token:, errors: result[:errors]) }
        .on_success do |result|
          warden.set_user(result[:user], scope: :user)

          redirect_to(users_root_path, notice: 'Your password has been changed successfully. You are now signed in.')
        end
    end

    private

      def render_edit(reset_password_token:, errors:)
        render('users/passwords/edit', locals: {reset_password_token:, form_errors: errors})
      end

      def forbid_access_and_redirect
        redirect_to(root_path, notice: 'You cannot perform this action.')
      end
  end
end
