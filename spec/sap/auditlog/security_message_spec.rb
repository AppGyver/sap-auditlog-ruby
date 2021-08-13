# frozen_string_literal: true

RSpec.describe Sap::Auditlog::SecurityMessage do
  describe "#initialize" do
    let(:kind) { "security-events" }
    let(:object) { "5 unsuccessful login attempts" }
    let(:subject) { described_class.new(object: object) }

    it "constucts a 'security-events' instance" do
      expect(subject.kind).to eq kind
      expect(subject.object).to eq object
    end
  end

  describe "#payload" do
    let(:kind) { "security-events" }
    let(:object) { "5 unsuccessful login attempts" }
    let(:subject) { described_class.new(object: object) }

    let(:common_payload) { { mock: "common payload" } }
    let(:data_subject1) { { type: "test type", id: "test id" } }
    let(:ip) { "127.0.0.1" }
    before do
      allow(subject)
        .to receive(:common_payload)
        .and_return(common_payload)
    end

    it "has payload specific to its kind" do
      subject
        .external_ip!(ip)
        .data_subject!(data_subject1)

      expect(subject.payload).to eq(
        MultiJson.dump(
          {
            mock: "common payload",
            data: object,
            data_subjects: [data_subject1],
            ip: ip
          }
        )
      )
    end
  end
end
