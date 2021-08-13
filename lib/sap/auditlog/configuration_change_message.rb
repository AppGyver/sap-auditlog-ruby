# frozen_string_literal: true

module Sap
  module Auditlog
    # See also
    # https://www.npmjs.com/package/@sap/audit-logging#configuration-change-messages-1
    class ConfigurationChangeMessage < Message
      def initialize(object:)
        super(kind: "configuration-changes", object: object)
      end

      def payload
        raise InvalidPayloadError, "Validation errors: #{errors}" unless valid?

        MultiJson.dump(
          common_payload.merge(
            {
              object: object,
              attributes: attributes,
              data_subjects: data_subjects
            }
          )
        )
      end

      def valid?
        validate_common_object

        super
      end
    end
  end
end
