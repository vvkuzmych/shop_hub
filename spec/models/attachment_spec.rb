# == Schema Information
#
# Table name: attachments
#
#  id              :bigint           not null, primary key
#  attachable_type :string           not null
#  file_name       :string           not null
#  file_size       :integer
#  file_type       :string
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachable_id   :bigint           not null
#
# Indexes
#
#  index_attachments_on_attachable                         (attachable_type,attachable_id)
#  index_attachments_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_attachments_on_file_type                          (file_type)
#
require "rails_helper"

RSpec.describe Attachment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:attachable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:file_name) }
    it { is_expected.to validate_numericality_of(:file_size).is_greater_than(0).allow_nil }
  end

  describe "scopes" do
    let!(:product) { create(:product) }
    let!(:image_attachment) { create(:attachment, attachable: product, file_type: "jpg") }
    let!(:document_attachment) { create(:attachment, attachable: product, file_type: "pdf") }
    let!(:video_attachment) { create(:attachment, attachable: product, file_type: "mp4") }

    describe ".images" do
      it "returns only image attachments" do
        expect(Attachment.images).to contain_exactly(image_attachment)
      end
    end

    describe ".documents" do
      it "returns only document attachments" do
        expect(Attachment.documents).to contain_exactly(document_attachment)
      end
    end

    describe ".videos" do
      it "returns only video attachments" do
        expect(Attachment.videos).to contain_exactly(video_attachment)
      end
    end

    describe ".recent" do
      it "returns attachments ordered by most recent first" do
        expect(Attachment.recent.first).to eq(video_attachment)
      end
    end
  end

  describe "polymorphic behavior" do
    let(:product) { create(:product) }
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }

    it "can be associated with a product" do
      attachment = create(:attachment, attachable: product)
      expect(attachment.attachable).to eq(product)
      expect(attachment.attachable_type).to eq("Product")
    end

    it "can be associated with a user" do
      attachment = create(:attachment, attachable: user)
      expect(attachment.attachable).to eq(user)
      expect(attachment.attachable_type).to eq("User")
    end

    it "can be associated with an order" do
      attachment = create(:attachment, attachable: order)
      expect(attachment.attachable).to eq(order)
      expect(attachment.attachable_type).to eq("Order")
    end
  end

  describe "#image?" do
    it "returns true for image file types" do
      attachment = create(:attachment, file_type: "jpg")
      expect(attachment.image?).to be true
    end

    it "returns false for non-image file types" do
      attachment = create(:attachment, file_type: "pdf")
      expect(attachment.image?).to be false
    end
  end

  describe "#document?" do
    it "returns true for document file types" do
      attachment = create(:attachment, file_type: "pdf")
      expect(attachment.document?).to be true
    end

    it "returns false for non-document file types" do
      attachment = create(:attachment, file_type: "jpg")
      expect(attachment.document?).to be false
    end
  end

  describe "#video?" do
    it "returns true for video file types" do
      attachment = create(:attachment, file_type: "mp4")
      expect(attachment.video?).to be true
    end

    it "returns false for non-video file types" do
      attachment = create(:attachment, file_type: "jpg")
      expect(attachment.video?).to be false
    end
  end

  describe "#file_size_human" do
    it "returns N/A when file_size is nil" do
      attachment = create(:attachment, file_size: nil)
      expect(attachment.file_size_human).to eq("N/A")
    end

    it "returns size in bytes for small files" do
      attachment = create(:attachment, file_size: 500)
      expect(attachment.file_size_human).to eq("500 B")
    end

    it "returns size in KB for medium files" do
      attachment = create(:attachment, file_size: 2048)
      expect(attachment.file_size_human).to eq("2.0 KB")
    end

    it "returns size in MB for large files" do
      attachment = create(:attachment, file_size: 2_097_152)
      expect(attachment.file_size_human).to eq("2.0 MB")
    end
  end

  describe "extract_file_info callback" do
    it "extracts file name and type from URL" do
      attachment = Attachment.new(
        url: "https://example.com/files/document.pdf",
        attachable: create(:product)
      )
      attachment.valid?

      expect(attachment.file_name).to eq("document.pdf")
      expect(attachment.file_type).to eq("pdf")
    end

    it "handles invalid URLs gracefully" do
      attachment = Attachment.new(
        url: "not a valid url",
        attachable: create(:product)
      )

      expect { attachment.valid? }.not_to raise_error
    end
  end
end
