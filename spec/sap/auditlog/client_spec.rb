# frozen_string_literal: true

RSpec.describe Sap::Auditlog::Client do
  let(:service_url) { "https://example.local" }
  let(:oauth_client) { instance_double("Mock OAuth Client") }
  let(:logger) { "logger" }
  let(:xs_audit_org) { "xs_audit_org" }
  let(:xs_audit_app) { "xs_audit_app" }
  let(:xs_audit_space) { "xs_audit_space" }
  let(:subject) do
    described_class.new(
      service_url: service_url,
      oauth_client: oauth_client,
      logger: logger,
      xs_audit_org: xs_audit_org,
      xs_audit_app: xs_audit_app,
      xs_audit_space: xs_audit_space
    )
  end

  describe "#initialize" do
    it "constructs an object" do
      expect(subject.service_url).to eq service_url
      expect(subject.oauth_client).to eq oauth_client
      expect(subject.logger).to eq logger
      expect(subject.xs_audit_org).to eq xs_audit_org
      expect(subject.xs_audit_app).to eq xs_audit_app
      expect(subject.xs_audit_space).to eq xs_audit_space
    end
  end

  describe "#request" do
    let(:object) { { type: "lolcat system", id: { name: "lolcats" } } }
    let(:data_subject1) { { type: "mock subject 1", id: "mock id 1" } }
    let(:data_subject2) { { type: "mock subject 2", id: "mock id 2" } }
    let(:attribute1) { { name: "attr 1", old: "1", new: "10" } }
    let(:attribute2) { { name: "attr 2", old: "2", new: "20" } }
    let(:message) do
      Sap::Auditlog::AccessMessage
        .new(object: object)
        .data_subject!(data_subject1)
        .data_subject!(data_subject2)
        .attribute!(attribute1)
        .attribute!(attribute2)
    end
    let(:uuid) { "mock_uuid" }
    let(:fixed_time) { Time.local(2021, 8, 11, 16, 20, 1) }
    let(:request_data) { "mock request data" }
    let(:bearer_token) { "mock bearer token" }
    let(:request_headers) do
      {
        "User-Agent" => "SAP AppGyver Auditlog v#{Sap::Auditlog::VERSION}",
        "Content-Type" => "application/json",
        "XS_AUDIT_ORG" => xs_audit_org,
        "XS_AUDIT_SPACE" => xs_audit_space,
        "XS_AUDIT_APP" => xs_audit_app,
        "Authorization" => "Bearer #{bearer_token}"
      }
    end
    let(:response) { instance_double(Faraday::Response) }
    let(:access_token) { instance_double("Mock Access Token") }
    let(:api_url) { "#{service_url}/#{message.kind}" }
    before do
      allow(access_token)
        .to receive(:expired?)
        .and_return(false)

      allow(access_token)
        .to receive(:token)
        .and_return(bearer_token)

      allow(subject)
        .to receive(:access_token)
        .and_return(access_token)

      allow(subject)
        .to receive(:json_payload)
        .and_return(request_data)

      allow(response)
        .to receive(:success?)
        .and_return(true)

      allow(SecureRandom)
        .to receive(:hex)
        .and_return(uuid)

      allow(Faraday)
        .to receive(:post)
        .with(api_url, request_data, request_headers)
        .and_return(response)
    end

    it "dispatches request" do
      Timecop.freeze(fixed_time) do
        expect(subject.request(message)).to eq response
      end
    end
  end
end
