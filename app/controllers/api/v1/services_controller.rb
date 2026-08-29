module Api
  module V1
    class ServicesController < BaseController
      def index
        services = Service.ordered
        render json: {
          services: services.map { |s| serialize_service(s) }
        }, status: :ok
      end

      def show
        service = Service.find(params[:id])
        render json: {
          service: serialize_service(service)
        }, status: :ok
      end

      def create
        service_params = params.require(:service).permit(
          :name,
          :description,
          :duration_minutes,
          :price_cents,
          :currency,
          :active,
          :sort_order
        )

        # Se o preço foi passado em reais via price_in_reais ou price float/string
        if params[:service][:price].present?
          service_params[:price_cents] = (params[:service][:price].to_f * 100).round
        end

        service = Service.new(service_params)
        service.tenant = current_tenant

        if service.save
          render json: {
            status: "success",
            message: "Serviço cadastrado com sucesso",
            service: serialize_service(service)
          }, status: :created
        else
          render json: {
            error: "Falha ao cadastrar serviço",
            errors: service.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def serialize_service(service)
        {
          id: service.id,
          name: service.name,
          description: service.description,
          duration_minutes: service.duration_minutes,
          price_cents: service.price_cents,
          price_formatted: service.formatted_price,
          currency: service.currency,
          active: service.active,
          sort_order: service.sort_order,
          created_at: service.created_at
        }
      end
    end
  end
end
