# frozen_string_literal: true

module Sap
  module Auditlog
    # See also
    # https://www.npmjs.com/package/@sap/audit-logging#general-security-messages-1
    class SecurityMessage < Message
      attr_reader :external_ip

      def initialize(object:)
        super(kind: "security-events", object: object)
      end

      def payload
        raise InvalidPayloadError, "Validation errors: #{errors}" unless valid?

        MultiJson.dump(
          common_payload.merge(
            {
              object: object,
              data_subjects: data_subjects,
              ip: external_ip,
            }
          )
        )
      end

      def valid?
        raise InvalidPayloadError, "Main object is expected to be a string" unless object.is_a?(String)

        super
      end

      def external_ip!(ip)
        @external_ip = ip

        self
      end
    end
  end
end
