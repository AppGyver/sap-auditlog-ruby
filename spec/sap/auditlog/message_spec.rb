# frozen_string_literal: true

RSpec.describe Sap::Auditlog::Message do
  describe "#initialize" do
    let(:kind) { "any_kind" }
    let(:object) { "any_object" }
    let(:subject) { described_class.new(kind: kind, object: object) }

    it "constucts an object" do
      expect(subject.kind).to eq kind
      expect(subject.object).to eq object
    end
  end

  describe "#attribute" do
    let(:kind) { "read" }
    let(:object) { "some_object" }

    let(:attr_name) { "lolcat_attr" }
    let(:old_value) { "old_lolcat" }
    let(:new_value) { "new_lolcat" }
    let(:subject) { described_class.new(kind: kind, object: object) }

    it "constructs an event without values" do
      expect(subject.attributes).to be_empty

      subject.attribute!(name: attr_name)

      expect(subject.attributes).to eq([{ name: attr_name }])
    end

    it "constructs an event with new and old values" do
      expect(subject.attributes).to be_empty

      subject.attribute!(name: attr_name, old: old_value, new: new_value)

      expect(subject.attributes).to eq(
        [
          { name: attr_name, old: old_value, new: new_value }
        ]
      )
    end

    it "constructs an event with only new value" do
      expect(subject.attributes).to be_empty

      subject.attribute!(name: attr_name, new: new_value)

      expect(subject.attributes).to eq(
        [
          { name: attr_name, new: new_value }
        ]
      )
    end

    it "constructs an event with only old value" do
      expect(subject.attributes).to be_empty

      subject.attribute!(name: attr_name, old: old_value)

      expect(subject.attributes).to eq(
        [
          { name: attr_name, old: old_value }
        ]
      )
    end

    context "args" do
      it "raises error when name is not present" do
        expect do
          subject.attribute!({ id: "name attr not present" })
        end.to raise_error ArgumentError
      end

      it "raises ArgumentError when opts is not a Hash" do
        expect do
          subject.attribute!("not a hash")
        end.to raise_error ArgumentError
      end
    end

    context "chaining multiple attributes in a single call" do
      let(:attr_name2) { "second_attr" }
      let(:old_value2) { "second_old_value" }
      let(:new_value2) { "second_new_value" }

      it "constructs one message for multiple attributes" do
        expect(subject.attributes).to be_empty

        subject
          .attribute!(name: attr_name, old: old_value, new: new_value)
          .attribute!(name: attr_name2, old: old_value2, new: new_value2)

        expect(subject.attributes).to eq(
          [
            { name: attr_name, old: old_value, new: new_value },
            { name: attr_name2, old: old_value2, new: new_value2 }
          ]
        )
      end
    end

    describe "#data_subject" do
      let(:kind) { "some_kind" }
      let(:object) { "some_object" }
      let(:type1) { "student" }
      let(:id1) do
        { student_id: "st_123" }
      end
      let(:role1) { "foreign student" }

      it "constructs data_subjects with role" do
        expect(subject.data_subjects).to be_empty

        subject.data_subject!(type: type1, id: id1, role: role1)

        expect(subject.data_subjects).to eq(
          [
            { id: id1, type: type1, role: role1 }
          ]
        )
      end

      it "constructs data_subjects without role" do
        expect(subject.data_subjects).to be_empty

        subject.data_subject!(type: type1, id: id1)

        expect(subject.data_subjects).to eq(
          [
            { id: id1, type: type1 }
          ]
        )
      end

      context "chaining multiple data_subjects in a single call" do
        let(:type2) { "student2" }
        let(:id2) do
          { student_id: "st_456" }
        end
        let(:role2) { "foreign student 2" }

        it "constructs one message for multiple data_subjects" do
          expect(subject.data_subjects).to be_empty

          subject
            .data_subject!(type: type1, id: id1)
            .data_subject!(type: type2, id: id2, role: role2)

          expect(subject.data_subjects).to eq(
            [
              { id: id1, type: type1 },
              { id: id2, type: type2, role: role2 }
            ]
          )
        end
      end
    end

    describe "chaining all the methods together" do
      it "returns itself" do
        expect(
          subject
            .attribute!(name: "attr1")
            .attribute!(name: "attr2")
            .data_subject!(type: "type", id: "id")
            .data_subject!(type: "type2", id: "id2")
            .access_channel!("channel")
            .tenant!("tenant")
            .by!("actor")
            .external_ip!("ip")
        ).to eq subject
      end
    end
  end

  describe "#tenant" do
    let(:kind) { "any_kind" }
    let(:object) { "any_object" }
    let(:subject) { described_class.new(kind: kind, object: object) }
    let(:default_value) { "$PROVIDER" }
    let(:explicit_value) { "test_tenant" }

    it "returns the set value" do
      expect(subject.tenant!(explicit_value)).to eq subject
      expect(subject.tenant).to eq explicit_value
    end

    it "returns default value if value is not set" do
      expect(subject.tenant).to eq default_value
    end
  end

  describe "#by" do
    let(:kind) { "any_kind" }
    let(:object) { "any_object" }
    let(:subject) { described_class.new(kind: kind, object: object) }
    let(:default_value) { "$USER" }
    let(:explicit_value) { "test_tenant" }

    it "returns the set value" do
      expect(subject.by!(explicit_value)).to eq subject
      expect(subject.by).to eq explicit_value
    end

    it "returns default value if value is not set" do
      expect(subject.by).to eq default_value
    end
  end

  describe "#common_payload" do
    let(:kind) { "any_kind" }
    let(:object) { "any_object" }
    let(:subject) { described_class.new(kind: kind, object: object) }
    let(:fixed_time) { Time.local(2021, 8, 11, 16, 20, 1) }
    let(:uuid) { "mock_uuid" }

    before do
      allow(SecureRandom)
        .to receive(:hex)
        .and_return(uuid)
    end

    it "has payload for all message kinds" do
      Timecop.freeze(fixed_time) do
        expect(subject.common_payload).to eq(
          {
            tenant: "$PROVIDER",
            user: "$USER",
            uuid: uuid,
            time: fixed_time.utc.iso8601
          }
        )
      end
    end
  end
end
