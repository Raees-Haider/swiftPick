# config/initializers/stripe.rb
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

if Stripe.api_key.blank?
  if Rails.env.production?
    raise "STRIPE_SECRET_KEY environment variable is not set"
  else
    Rails.logger.warn "WARNING: STRIPE_SECRET_KEY environment variable is not set. Stripe functionality will not work."
  end
end
