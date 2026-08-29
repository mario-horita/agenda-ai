module Public
  class SlotsController < ApplicationController
    def index
      service = current_tenant.services.active.find_by(id: params[:service_id])
      unless service
        return render json: { error: "Serviço não encontrado" }, status: :not_found
      end

      date_param = params[:date].presence || Date.current.to_s
      date = begin
        Date.parse(date_param)
      rescue ArgumentError
        return render json: { error: "Data inválida" }, status: :unprocessable_content
      end

      professional = if params[:professional_id].present?
                       current_tenant.professionals.active.find_by(id: params[:professional_id])
      end

      if params[:professional_id].present? && professional.nil?
        return render json: { error: "Profissional não encontrado" }, status: :not_found
      end

      finder = Slots::SlotFinder.new(
        tenant: current_tenant,
        service: service,
        date: date,
        professional: professional
      )

      slots = finder.available_slots_combined

      respond_to do |format|
        format.json do
          render json: {
            date: date.to_s,
            service_id: service.id,
            professional_id: professional&.id,
            slots_count: slots.size,
            slots: slots
          }
        end
        format.html do
          render partial: "public/slots/slots_list", locals: { slots: slots, date: date, service: service, professional: professional }
        end
      end
    end
  end
end
