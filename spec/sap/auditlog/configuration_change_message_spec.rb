# frozen_string_literal: true

RSpec.describe Sap::Auditlog::ConfigurationChangeMessage do
  describe "#initialize" do
    let(:kind) { "configuration-changes" }
    let(:object) do
      {
        type: "online system",
        id: {
          name: "Students info system",
          configuration: "global-config"
        }
      }
    end
    let(:subject) { described_class.new(object: object) }

    it "constucts a 'configuration-changes' instance" do
      expect(subject.kind).to eq kind
      expect(subject.object).to eq object
    end
  end

  describe "#payload" do
    let(:object) { { type: "something", id: { jes: "box" } } }
    let(:subject) { described_class.new(object: object) }
    let(:common_payload) { { mock: "common payload" } }
    let(:attr1) { { name: "attr1" } }
    let(:attr2) { { name: "attr2" } }

    before do
      allow(subject)
        .to receive(:common_payload)
        .and_return(common_payload)
    end

    it "has payload specific to its kind" do
      subject
        .attribute!(attr1)
        .attribute!(attr2)

      expect(subject.payload).to eq(
        MultiJson.dump(
          {
            mock: "common payload",
            object: object,
            attributes: [attr1, attr2]
          }
        )
      )
    end
  end
end
