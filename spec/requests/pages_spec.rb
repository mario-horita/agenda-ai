require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "renders the main landing page successfully" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Agenda")
      expect(response.body).to include("Sua agenda no piloto automático")
      expect(response.body).to include("Starter")
      expect(response.body).to include("Pro")
    end
  end
end
