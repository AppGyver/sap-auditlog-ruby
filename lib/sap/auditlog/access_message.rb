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
        common_payload.merge(
          {
            object: object,
            attributes: attributes,
            data_subjects: data_subjects,
            attachments: attachments,
            channel: access_channel
          }
        )
      end

      def valid?
        validate_object

        validation_error! "Attributes cannot be empty." if @attributes.nil? || @attributes.empty?
        validation_error! "Data subjects cannot be empty." if @data_subjects.nil? || @data_subjects.empty?
        validation_error! "By cannot be empty." if @by.nil? || @by.empty?

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

      private

      def validate_object
        validation_error!("Object is empty.") if @object.nil? || @object.empty?
        validation_error!("Object :type missing.") if @object[:type].nil?
        validation_error!("Object :id missing.") if @object[:id].nil?
      end
    end
  end
end
