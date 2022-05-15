# frozen_string_literal: true

module Users
  class PasswordsController < BaseController
    def new
      render('users/passwords/new')
    end

    def create
      email = params.require(:user).fetch(:email)

      if email.present? && ::URI::MailTo::EMAIL_REGEXP.match?(email)
        reset_password_token = ::SecureRandom.uuid

        updated = ::User.where(email:).update_all(reset_password_token:).nonzero?

        ::UserMailer.with(email:, reset_password_token:).reset_password.deliver_later if updated
      end

      notice = 'You will receive an email with instructions for how to confirm your email address in a few minutes.'

      redirect_to(root_path, notice:)
    end

    def edit
      reset_password_token = params[:uuid]

      return render_edit(reset_password_token:, errors: nil) if ::User.exists?(reset_password_token:)

      notice =
        "You can't access this page without coming from a password reset email. " \
        'If you do come from a password reset email, please make sure you used the full URL provided.'

      redirect_to(root_path, notice:)
    end

    def update
      reset_password_token = params[:uuid]

      user = ::User.find_by(reset_password_token:)

      return redirect_to(root_path, notice: 'You cannot perform this action.') unless user

      user_params = params.require(:user).permit(:password, :password_confirmation)

      password = String(user_params[:password]).strip
      password_confirmation = String(user_params[:password_confirmation]).strip

      errors = {}
      errors[:password] = "can't be blank" if password.blank?
      errors[:password] ||= 'is too short (minimum: 6)' if password.size < 6
      errors[:password_confirmation] = "can't be blank" if password_confirmation.blank?
      errors[:password_confirmation] ||= "doesn't match password" if password != password_confirmation

      return render_edit(reset_password_token:, errors: errors) if errors.present?

      encrypted_password = ::BCrypt::Password.create(password)

      user.update!(encrypted_password:, reset_password_token: nil)

      warden.set_user(user, scope: :user)

      redirect_to(users_root_path, notice: 'Your password has been changed successfully. You are now signed in.')
    end

    private

      def render_edit(reset_password_token:, errors:)
        render('users/passwords/edit', locals: {reset_password_token:, form_errors: errors})
      end
  end
end
