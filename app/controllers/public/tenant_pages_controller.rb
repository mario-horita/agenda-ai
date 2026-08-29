module Public
  class TenantPagesController < ApplicationController
    layout "public"

    def show
      @tenant = current_tenant
    end
  end
end
