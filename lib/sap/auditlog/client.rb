# frozen_string_literal: true

require "faraday"
require "multi_json"
require "securerandom"
require "time"

module Sap
  module Auditlog
    class Client
      class RequestFailure < StandardError; end

      class InvalidMessageType < StandardError; end

      class InvalidMessagePayload < StandardError; end

      attr_reader :service_url, :oauth_client, :logger, :xs_audit_org, :xs_audit_space, :xs_audit_app

      def initialize(service_url:, oauth_client:, logger:, xs_audit_org:, xs_audit_space:, xs_audit_app:)
        @service_url = service_url
        @oauth_client = oauth_client
        @logger = logger
        @xs_audit_org = xs_audit_org
        @xs_audit_app = xs_audit_app
        @xs_audit_space = xs_audit_space
      end

      def request(message)
        raise InvalidMessageType unless message.is_a?(::Sap::Auditlog::Message)
        raise InvalidMessagePayload, "Validation errors: #{message.errors}" unless message.valid?

        dispatch(message)
      end

      private

      def access_token
        @access_token = fetch_access_token if @access_token.nil? || @access_token.expired?

        @access_token
      end

      def fetch_access_token
        oauth_client.client_credentials.get_token
      end

      def json_payload(message)
        MultiJson.dump(message.payload)
      end

      def request_headers
        {
          "User-Agent" => "SAP AppGyver Auditlog v#{Sap::Auditlog::VERSION}",
          "Content-Type" => "application/json",
          "XS_AUDIT_ORG" => xs_audit_org,
          "XS_AUDIT_SPACE" => xs_audit_space,
          "XS_AUDIT_APP" => xs_audit_app,
          "Authorization" => "Bearer #{access_token.token}"
        }
      end

      def api_url(base_url, message)
        [base_url, message.kind].join "/"
      end

      def dispatch(message)
        response = Faraday.post(
          api_url(service_url, message),
          json_payload(message),
          request_headers
        )

        unless response.success?
          Rails.logger.error <<-ERROR.squish
            Failed Auditlog post:
            api: '#{api_url(service_url, message)}',
            xs_audit_org: '#{xs_audit_org}',
            xs_audit_app: '#{xs_audit_app}',
            xs_audit_space: '#{xs_audit_space}',
            payload: '#{json_payload(message)}'
          ERROR

          raise RequestFailure, "HTTP #{response.status} - Failed posting to SAP AuditLog: #{response.body}"
        end

        response
      end
    end
  end
end
