# frozen_string_literal: true

RSpec.describe Sap::Auditlog::AccessMessage do
  describe "#initialize" do
    let(:kind) { "data-accesses" }
    let(:object) do
      {
        type: "online system",
        id: {
          name: "Students info system",
          module: "Foreign students"
        }
      }
    end
    let(:subject) { described_class.new(object: object) }

    it "constucts a 'data-accesses' instance" do
      expect(subject.kind).to eq kind
      expect(subject.object).to eq object
    end

    describe "#attachment!" do
      let(:id1) { 1234 }
      let(:id2) { 3456 }
      let(:name2) { "lolcat2" }

      it "constructs an attachment" do
        expect(subject.attachments).to be_empty

        subject
          .attachment!(id: id1)
          .attachment!(id: id2, name: name2)

        expect(subject.attachments).to eq(
          [
            { id: id1 },
            { id: id2, name: name2 }
          ]
        )
      end
    end

    describe "#payload" do
      let(:kind) { "asdf" }
      let(:object) { { type: "something", id: { jes: "box" } } }
      let(:subject) { described_class.new(object: object) }
      let(:common_payload) { { mock: "common payload" } }
      let(:attr1) { { name: "attr1" } }
      let(:data_subject1) { { type: "test type", id: "test id" } }
      let(:attachment1) { { id: "attachment1" } }
      let(:attachment2) { { id: "attachment2" } }
      let(:access_channel) { "mock access channel" }

      before do
        allow(subject)
          .to receive(:common_payload)
          .and_return(common_payload)
      end

      it "has payload specific to its kind" do
        subject
          .attribute!(attr1)
          .data_subject!(data_subject1)
          .attachment!(attachment1)
          .attachment!(attachment2)
          .access_channel!(access_channel)

        expect(subject.payload).to eq(
          MultiJson.dump(
            {
              mock: "common payload",
              object: object,
              attributes: [attr1],
              data_subjects: [data_subject1],
              attachments: [attachment1, attachment2],
              channel: access_channel
            }
          )
        )
      end
    end
  end
end
