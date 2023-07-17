# frozen_string_literal: true

module SMTPExtends
  private

  def build_smtp_session
    Net::SMTP.new(settings[:address], settings[:port]).tap do |smtp|
      tls = settings[:tls] || settings[:ssl]
      if !tls.nil?
        case tls
        when true
          smtp.enable_tls(ssl_context)
        when false
          smtp.disable_tls
        else
          raise ArgumentError, "Unrecognized :tls value #{settings[:tls].inspect}; expected true, false, or nil"
        end
      elsif settings.include?(:enable_starttls) && !settings[:enable_starttls].nil?
        case settings[:enable_starttls]
        when true
          smtp.enable_starttls(ssl_context)
        when false
          smtp.disable_starttls
        else
          raise ArgumentError, "Unrecognized :enable_starttls value #{settings[:enable_starttls].inspect}; expected true, false, or nil"
        end
      elsif settings.include?(:enable_starttls_auto) && !settings[:enable_starttls_auto].nil?
        case settings[:enable_starttls_auto]
        when true
          smtp.enable_starttls_auto(ssl_context)
        when false
          smtp.disable_starttls
        else
          raise ArgumentError, "Unrecognized :enable_starttls_auto value #{settings[:enable_starttls_auto].inspect}; expected true, false, or nil"
        end
      end

      if Rails.application.secrets.smtp_starttls_auto == false
        smtp.disable_starttls
      end

      if Rails.application.secrets.smtp_tls == false
        smtp.disable_tls
      end

      byebug

      smtp.open_timeout = settings[:open_timeout] if settings[:open_timeout]
      smtp.read_timeout = settings[:read_timeout] if settings[:read_timeout]
    end
  end
end

Mail::SMTP.class_eval do
  prepend(SMTPExtends)
end
