# frozen_string_literal: true

module Sap
  module Auditlog
    # See also
    # https://www.npmjs.com/package/@sap/audit-logging#data-access-messages-1
    class ModificationMessage < Message
      def initialize(object:)
        super(kind: "data-modifications", object: object)

        @attachments = []
      end

      def payload
        raise InvalidPayloadError, "Validation errors: #{errors}" unless valid?

        MultiJson.dump(
          common_payload.merge(
            {
              object: object,
              attributes: attributes,
              data_subject: data_subjects.first
            }
          )
        )
      end

      def valid?
        validate_common_object
        validate_data_subject

        super
      end

      private

      def validate_data_subject
        validation_error! "#{self.class} can only have a single 'data_subject'" unless data_subjects.size == 1
        validation_error! "#{self.class} Attributes cannot be empty." if @attributes.nil? || @attributes.empty?
      end
    end
  end
end
