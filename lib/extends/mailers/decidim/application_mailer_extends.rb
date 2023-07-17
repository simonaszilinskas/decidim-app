# frozen_string_literal: true

module ApplicationMailerExtends
  private

  def set_smtp
    return if @organization.nil? || @organization.smtp_settings.blank?

    mail.from = @organization.smtp_settings["from"].presence || mail.from
    mail.reply_to = mail.reply_to || Decidim.config.mailer_reply

    delivery_settings = mail.delivery_method.settings.merge(
      address: @organization.smtp_settings["address"],
      port: @organization.smtp_settings["port"],
      user_name: @organization.smtp_settings["user_name"],
      password: Decidim::AttributeEncryptor.decrypt(@organization.smtp_settings["encrypted_password"])
    ) { |_k, o, v| o || v }.reject! { |_k, v| v.blank? }

    if Rails.application.secrets.smtp_starttls_auto.present?
      delivery_settings[:enable_starttls_auto] = Rails.application.secrets.smtp_starttls_auto
      delivery_settings[:enable_starttls] = Rails.application.secrets.smtp_starttls_auto
    end

    if Rails.application.secrets.smtp_tls.present?
      delivery_settings[:ssl] = Rails.application.secrets.smtp_tls
      delivery_settings[:tls] = Rails.application.secrets.smtp_tls
    end

    if Rails.application.secrets.smtp_openssl_verify_mode.present?
      delivery_settings[:openssl_verify_mode] = Rails.application.secrets.smtp_openssl_verify_mode
    end
    byebug

    mail.delivery_method.settings = delivery_settings
  end
end

Decidim::ApplicationMailer.class_eval do
  prepend(ApplicationMailerExtends)
end
