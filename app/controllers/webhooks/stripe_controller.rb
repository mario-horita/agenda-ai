require "ostruct"

module Webhooks
  class StripeController < ActionController::API
    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      webhook_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)

      event = begin
        if webhook_secret.present? && !Rails.env.test?
          Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
        else
          data = JSON.parse(payload, object_class: OpenStruct)
          Stripe::Event.construct_from(data.to_h)
        end
      rescue JSON::ParserError
        return render json: { error: "Invalid payload" }, status: :bad_request
      rescue Stripe::SignatureVerificationError
        return render json: { error: "Invalid signature" }, status: :bad_request
      end

      StripeServices::WebhookHandler.new(event).call

      render json: { received: true }, status: :ok
    end
  end
end
