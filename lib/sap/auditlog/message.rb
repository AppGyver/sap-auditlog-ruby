# frozen_string_literal: true

module Sap
  module Auditlog
    # See also
    # https://www.npmjs.com/package/@sap/audit-logging
    class Message
      class InvalidPayloadError < StandardError; end

      attr_reader :errors, :kind, :object, :attributes, :data_subjects, :access_channel, :external_ip,
                  :tenant, :by

      def initialize(kind:, object:)
        @kind = kind
        @object = object
        @attributes = []
        @data_subjects = []
        @errors = []
        @by = "$USER"
        @tenant = "$PROVIDER"
      end

      def common_payload
        {
          tenant: tenant,
          user: by,
          uuid: SecureRandom.hex(16),
          time: Time.now.utc.iso8601
        }
      end

      # Using opts instead of explicit hash params because "new" is a reserved keyword.
      def attribute!(opts = {})
        raise ArgumentError, "Missing 'name' from 'attribute!' (Hash expected)" unless opts.is_a?(Hash) && opts[:name]

        msg = { name: opts[:name] }
        msg[:old] = opts[:old] if opts[:old]
        msg[:new] = opts[:new] if opts[:new]

        @attributes << msg

        self
      end

      def data_subject!(type:, id:, role: nil)
        msg = { type: type, id: id }
        msg[:role] = role if role

        @data_subjects << msg

        self
      end

      def tenant!(tenant_id)
        @tenant = tenant_id

        self
      end

      def by!(actor)
        @by = actor

        self
      end

      def external_ip!(ip)
        @external_ip = ip

        self
      end

      def valid?
        @errors.empty?
      end

      protected

      def validation_error!(msg)
        @errors << msg
      end
    end
  end
end
