module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

      private

      def authenticate_api_token!
        token = extract_token_from_header
        @current_user = User.find_by_api_token(token) if token.present?

        unless @current_user
          render json: { error: "Não autorizado", message: "Token de API inválido ou expirado" }, status: :unauthorized
          return
        end

        ActsAsTenant.current_tenant = @current_user.tenant
      end

      def current_user
        @current_user
      end

      def current_tenant
        @current_user&.tenant
      end

      def extract_token_from_header
        auth_header = request.headers["Authorization"]
        return nil if auth_header.blank?

        # Suporta formatos "Bearer <token>" ou "<token>"
        auth_header.start_with?("Bearer ") ? auth_header.split(" ", 2).last : auth_header
      end

      def render_not_found(exception)
        render json: { error: "Recurso não encontrado", detail: exception.message }, status: :not_found
      end

      def render_unprocessable_entity(exception)
        render json: { error: "Dados inválidos", errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
