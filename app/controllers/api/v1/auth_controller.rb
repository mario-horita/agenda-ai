module Api
  module V1
    class AuthController < ActionController::API
      def token
        email = params[:email].to_s.strip.downcase
        password = params[:password].to_s

        user = User.find_by(email: email)

        if user&.valid_password?(password)
          token = user.generate_api_token
          render json: {
            token: token,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role
            },
            tenant: {
              id: user.tenant.id,
              name: user.tenant.name,
              slug: user.tenant.slug
            }
          }, status: :ok
        else
          render json: { error: "Credenciais inválidas", message: "Email ou senha incorretos" }, status: :unauthorized
        end
      end
    end
  end
end
