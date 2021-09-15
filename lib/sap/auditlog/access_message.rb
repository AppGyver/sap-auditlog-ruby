# frozen_string_literal: true

module Sap
  module Auditlog
    # See also
    # https://www.npmjs.com/package/@sap/audit-logging#data-access-messages-1
    class AccessMessage < Message
      attr_reader :attachments, :access_channel

      def initialize(object:)
        super(kind: "data-accesses", object: object)

        @attachments = []
      end

      def payload
        raise InvalidPayloadError, "Validation errors: #{errors}" unless valid?

        payload = common_payload.merge(
          {
            object: object,
            attributes: attributes
          }
        )

        payload.merge!(attachments: attachments) unless attachments.empty?
        payload.merge!(channel: access_channel) if access_channel

        if data_subjects.size == 1
          payload.merge!(data_subject: data_subjects.first)
        else
          payload.merge!(data_subjects: data_subjects)
        end

        MultiJson.dump(payload)
      end

      def valid?
        validate_common_object

        validation_error! "#{self.class} Attributes cannot be empty." if @attributes.nil? || @attributes.empty?
        validation_error! "#{self.class} Data subjects cannot be empty." if @data_subjects.nil? || @data_subjects.empty?
        validation_error! "#{self.class} By cannot be empty." if @by.nil? || @by.empty?

        super
      end

      def attachment!(id:, name: nil)
        msg = { id: id }
        msg[:name] = name if name

        @attachments << msg

        self
      end

      def access_channel!(name)
        @access_channel = name

        self
      end
    end
  end
end
