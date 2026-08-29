module Admin
  class SettingsController < BaseController
    def edit
      @tenant = current_tenant
      @setting = @tenant.tenant_setting || @tenant.create_tenant_setting!
    end

    def update
      @tenant = current_tenant
      @setting = @tenant.tenant_setting || @tenant.create_tenant_setting!

      tenant_saved = @tenant.update(tenant_params)
      setting_saved = @setting.update(setting_params)

      if tenant_saved && setting_saved
        redirect_to edit_admin_setting_path(tenant_slug: @tenant.slug),
                    notice: "Configurações atualizadas com sucesso!"
      else
        flash.now[:alert] = "Não foi possível salvar as configurações."
        render :edit, status: :unprocessable_content
      end
    end

    private

    def tenant_params
      params.require(:tenant).permit(:name, :phone, :primary_color, :secondary_color, :timezone)
    end

    def setting_params
      p = params.require(:tenant_setting).permit(
        :cancellation_window_hours,
        :reminder_hours,
        :allow_reschedule,
        :slot_interval_minutes,
        notification_channels: []
      )
      if p[:notification_channels].is_a?(Array)
        p[:notification_channels] = p[:notification_channels].reject(&:blank?).join(",")
      end
      p
    end
  end
end
