class DeterLab

  # Standard DeterLab interface error
  class Error < StandardError; end

  # Returns the current version of the deter lab
  def self.version
    Rails.cache.fetch('deterlab.version', expires_in: 15.minutes) do
      response = client("ApiInfo").call(:get_version)
      data = response.to_hash[:get_version_response][:return]
      "#{data[:version]}/#{data[:patch_level]}"
    end
  end

  # Checks if there's a user with the given #uid and #password
  def self.valid_credentials?(uid, password)
    cl = client("Users")
    challenge_id = call_request_challenge(cl, uid)
    response = call_challenge_response(cl, challenge_id, password)
    extract_and_store_certs(uid, Base64.decode64(response.to_hash[:challenge_response_response][:return]))

    return true
  rescue Savon::SOAPFault, Error
    return false
  end

  # Logs the user out
  def self.logout(uid)
    cl = client("Users", uid)
    cl.call(:logout)
  end

  private

  # extracts certs from the challenge response and stores them for later use
  def self.extract_and_store_certs(uid, x509s)
    cert = x509s.match(/-----BEGIN CERTIFICATE-----.*-----END CERTIFICATE-----/m)[0]
    key  = x509s.match(/-----BEGIN RSA PRIVATE KEY-----.*-----END RSA PRIVATE KEY-----/m)[0]
    raise Error unless cert.present? && key.present?
    SslKeyStorage.put(uid, cert, key)
  end

  # returns challenge ID of the request
  def self.call_request_challenge(cl, user_id)
    response = cl.call(:request_challenge,
      "message" => {
        "uid"   => user_id,
        "types" => "clear",
        :order! => [ :uid, :types ] })

    raise Error unless response.success?

    return response.to_hash[:request_challenge_response][:return][:challenge_id]
  end

  def self.call_challenge_response(cl, challenge_id, password)
    encoded_data = Base64.encode64(password)

    response = cl.call( :challenge_response,
      "message" => {
        "challengeID"  => challenge_id,
        "responseData" => encoded_data,
        :order!        => [ :responseData, :challengeID ] })

    raise Error unless response.success?

    return response
  end

  # Returns the client instance
  def self.client(service, uid = nil)
    options = {
      wsdl:             AppConfig['deter_lab']['wsdl'] % service,
      log_level:        :debug,
      log:              !Rails.env.test?,
      pretty_print_xml: true,
      soap_version:     2,
      namespace:        'http://api.testbed.deterlab.net/xsd',
      logger:           Rails.logger,
      filters:          :password,
      ssl_verify_mode:  :none }

    # optionally user user certs from the storage
    if uid.present?
      cert, key = SslKeyStorage.get(uid)
      if cert.present? && key.present?
        options[:ssl_cert] = OpenSSL::X509::Certificate.new(cert)
        options[:ssl_cert_key] = OpenSSL::PKey.read(key)
      else
        raise Error, "Not logged in as: #{uid}"
      end
    end

    Savon.client(options)
  end

end
