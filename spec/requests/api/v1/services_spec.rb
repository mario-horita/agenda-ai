require "rails_helper"

RSpec.describe "Api::V1::Services", type: :request do
  let!(:tenant) { create(:tenant, name: "Salão Premier", slug: "salao-premier") }
  let!(:user) { create(:user, tenant: tenant, email: "admin@premier.com", password: "password123") }
  let(:token) { user.generate_api_token }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" } }

  describe "POST /api/v1/services" do
    let(:valid_params) do
      {
        service: {
          name: "Corte e Barba VIP",
          description: "Serviço completo com toalha quente",
          duration_minutes: 45,
          price_cents: 8500,
          currency: "BRL",
          active: true
        }
      }.to_json
    end

    context "com token válido" do
      it "cadastra o serviço com sucesso para o tenant do usuário" do
        expect {
          post "/api/v1/services", params: valid_params, headers: headers
        }.to change(Service, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["service"]["name"]).to eq("Corte e Barba VIP")
        expect(json["service"]["duration_minutes"]).to eq(45)
        expect(json["service"]["price_cents"]).to eq(8500)
        expect(json["service"]["price_formatted"]).to include("85,00")
      end

      it "aceita preço em reais no formato float/string" do
        params = {
          service: {
            name: "Manicure",
            duration_minutes: 30,
            price: "45.50"
          }
        }.to_json

        post "/api/v1/services", params: params, headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["service"]["price_cents"]).to eq(4550)
      end

      it "retorna 422 quando faltam campos obrigatórios" do
        invalid_params = { service: { name: "" } }.to_json

        post "/api/v1/services", params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Falha ao cadastrar serviço")
        expect(json["errors"]).to be_present
      end
    end

    context "sem token ou token inválido" do
      it "retorna 401 Unauthorized se header ausente" do
        post "/api/v1/services", params: valid_params

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Não autorizado")
      end

      it "retorna 401 Unauthorized com token incorreto" do
        post "/api/v1/services", params: valid_params, headers: { "Authorization" => "Bearer invalid_token" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/services" do
    let!(:service1) { create(:service, tenant: tenant, name: "Corte") }
    let!(:other_tenant) { create(:tenant, slug: "outro") }
    let!(:other_service) { create(:service, tenant: other_tenant, name: "Outro") }

    it "lista apenas os serviços do tenant autenticado" do
      get "/api/v1/services", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["services"].size).to eq(1)
      expect(json["services"].first["name"]).to eq("Corte")
    end
  end
end
