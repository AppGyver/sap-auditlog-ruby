# frozen_string_literal: true

require "faraday"
require "multi_json"
require "securerandom"
require "time"

module Sap
  module Auditlog
    class Client
      class DispatchError < StandardError; end

      attr_reader :service_url, :oauth_client, :logger, :xs_audit_org, :xs_audit_space, :xs_audit_app

      def initialize(service_url:, oauth_client:, logger:, xs_audit_org:, xs_audit_space:, xs_audit_app:)
        @service_url = service_url
        @oauth_client = oauth_client
        @logger = logger
        @xs_audit_org = xs_audit_org
        @xs_audit_app = xs_audit_app
        @xs_audit_space = xs_audit_space
      end

      def dispatch(kind:, json:)
        response = Faraday.post(
          api_url(service_url, kind),
          json,
          request_headers
        )

        unless response.success?
          Rails.logger.error <<-ERROR.squish
            Failed Auditlog post:
            api: '#{api_url(service_url, kind)}',
            xs_audit_org: '#{xs_audit_org}',
            xs_audit_app: '#{xs_audit_app}',
            xs_audit_space: '#{xs_audit_space}',
            payload: '#{json}'
          ERROR

          raise DispatchError, "HTTP #{response.status} - Failed posting to SAP AuditLog: #{response.body}"
        end

        response
      end

      private

      def access_token
        @access_token = fetch_access_token if @access_token.nil? || @access_token.expired?

        @access_token
      end

      def fetch_access_token
        oauth_client.client_credentials.get_token
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

      def api_url(base_url, api_name)
        [base_url, api_name].join "/"
      end
    end
  end
end
