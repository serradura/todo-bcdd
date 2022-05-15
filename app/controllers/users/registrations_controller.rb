# frozen_string_literal: true

module Users
  class RegistrationsController < BaseController
    def new
      render_sign_up
    end

    def create
      user_params = params.require(:user).permit(:email, :password, :password_confirmation)

      email = String(user_params[:email]).strip.downcase
      password = String(user_params[:password]).strip
      password_confirmation = String(user_params[:password_confirmation]).strip

      errors = {}
      errors[:email] = 'is invalid' if email.blank? || !::URI::MailTo::EMAIL_REGEXP.match?(email)
      errors[:password] = "can't be blank" if password.blank?
      errors[:password] ||= 'is too short (minimum: 6)' if password.size < 6
      errors[:password_confirmation] = "can't be blank" if password_confirmation.blank?
      errors[:password_confirmation] ||= "doesn't match password" if password != password_confirmation

      return render_sign_up(email:, errors:) if errors.present?

      encrypted_password = ::BCrypt::Password.create(password)

      user = ::User.new(email:, encrypted_password:)

      if user.save
        ::UserMailer.with(email:).welcome.deliver_later

        warden.set_user(user, scope: :user)

        notice = 'Congratulations, your account has been successfully created.'

        redirect_to(users_root_url, notice:)
      else
        errors = user.errors.messages.transform_values { |messages| messages.join(', ') }

        render_sign_up(email:, errors:)
      end
    end

    private

      def render_sign_up(email: nil, errors: nil)
        render('users/registrations/new', locals: {
          user_email: email,
          form_errors: errors
        })
      end
  end
end
