module Admin
  class TimeBlocksController < BaseController
    before_action :set_professional

    def index
      @time_blocks = @professional.time_blocks.ordered
      @time_block = @professional.time_blocks.build(all_day: true, start_date: Date.current, end_date: Date.current)
    end

    def create
      @time_block = @professional.time_blocks.build(time_block_params)
      if @time_block.save
        redirect_to admin_professional_time_blocks_path(tenant_slug: current_tenant.slug, professional_id: @professional.id),
                    notice: "Bloqueio de horário registrado com sucesso."
      else
        @time_blocks = @professional.time_blocks.ordered
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @time_block = @professional.time_blocks.find(params[:id])
      @time_block.destroy
      redirect_to admin_professional_time_blocks_path(tenant_slug: current_tenant.slug, professional_id: @professional.id),
                  notice: "Bloqueio removido com sucesso."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:professional_id])
    end

    def time_block_params
      params.require(:time_block).permit(:start_date, :end_date, :start_time, :end_time, :reason, :all_day)
    end
  end
end
