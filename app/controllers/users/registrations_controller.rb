# frozen_string_literal: true

module Users
  class RegistrationsController < BaseController
    def new
      render_sign_up
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
