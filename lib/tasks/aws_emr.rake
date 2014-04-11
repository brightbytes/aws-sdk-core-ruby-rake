require 'aws-sdk-core'

namespace :aws do

  namespace :emr do
    
    desc "new"
    task :new, [:region] => [:env] do |t, args|
      emr = Aws::EMR.new(
      # :credentials (Credentials) — Your AWS account credentials. Defaults to a new Credentials object populated by :access_key_id, :secret_access_key and :session_token. See Plugins::Credentials for more details.
      # :endpoint (String) — The HTTP endpoint for this client. Normally you should not need to configure the :endpoint directly. It is constructed from the :region option. However, sometime you need to specify the full endpoint, especially when connecting to test endpoints. See Plugins::RegionalEndpoint for more details.
      # :http_continue_timeout (Float) — default: 1 — See Seahorse::Client::Plugins::NetHttp for more details.
      # :http_idle_timeout (Integer) — default: 5 — See Seahorse::Client::Plugins::NetHttp for more details.
      # :http_open_timeout (Integer) — default: 15 — See Seahorse::Client::Plugins::NetHttp for more details.
      # :http_proxy (String) — See Seahorse::Client::Plugins::NetHttp for more details.
      # :http_read_timeout (Integer) — default: 60 — See Seahorse::Client::Plugins::NetHttp for more details.
      # :http_wire_trace (Boolean) — default: false — See Seahorse::Client::Plugins::NetHttp for more details.
      # :log_level (Symbol) — default: :info — The log level to send messages to the logger at. See Seahorse::Client::Plugins::Logging for more details.
      # :log_formatter (Logging::LogFormatter) — The log formatter. Defaults to Seahorse::Client::Logging::Formatter.default. See Seahorse::Client::Plugins::Logging for more details.
      # :logger (Logger) — default: nil — The Logger instance to send log messages to. If this option is not set, logging will be disabled. See Seahorse::Client::Plugins::Logging for more details.
      # :raise_response_errors (Boolean) — default: true — When true, response errors are raised. See Seahorse::Client::Plugins::RaiseResponseErrors for more details.
      # :raw_json (Boolean) — default: false — When true, request parameters are not validated or translated. Request parameter keys and values are expected to be formated as they are expected by the service. Similarly, when :raw_json is enabled, response data is no longer translated. Instead it is simply the result of a JSON parse. See Plugins::JsonProtocol for more details.
      # :region (String) — The AWS region to connect to. The region is used to construct the client endpoint. Defaults to ENV['AWS_DEFAULT_REGION']. Also checks AWS_REGION and AMAZON_REGION. See Plugins::RegionalEndpoint for more details.
      # :retry_limit (Integer) — default: 3 — The maximum number of times to retry failed requests. Only ~ 500 level server errors and certain ~ 400 level client errors are retried. Generally, these are throttling errors, data checksum errors, networking errors, timeout errors and auth errors from expired credentials. See Plugins::RetryErrors for more details.
      # :secret_access_key (String) — Your AWS account secret access key. Defaults to ENV['AWS_SECRET_KEY']. Also checks AWS_SECRET_ACCESS_KEY and AMAZON_SECRET_ACCESS_KEY. See Plugins::Credentials for more details.
      # :session_token (String) — If your credentials are temporary session credentials, this should be the session token. Defaults to ENV['AWS_SESSION_TOKEN']. Also checks AMAZON_SESSION_TOKEN. See Plugins::Credentials for more details.
      # :sigv4_name (String) — Override the default service name used for signing sigv4 requests. See Plugins::SignatureV4 for more details.
      # :sigv4_region (String) — Override the default region name used for signing sigv4 requests. See Plugins::SignatureV4 for more details.
      # :ssl_ca_bundle (String) — See Seahorse::Client::Plugins::NetHttp for more details.
      # :ssl_ca_directory (String) — See Seahorse::Client::Plugins::NetHttp for more details.
      # :ssl_verify_peer (Boolean) — default: true — See Seahorse::Client::Plugins::NetHttp for more details.
      # :validate_params (Boolean) — default: true — When true, request parameters are validated before sending the request. See Seahorse::Client::Plugins::ParamValidation for more details.
      
      )
    end

  end

end
