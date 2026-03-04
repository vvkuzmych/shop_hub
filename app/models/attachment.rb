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
class Attachment < ApplicationRecord
  # Polymorphic association - can belong to Product, User, Order, etc.
  belongs_to :attachable, polymorphic: true

  # Validations
  validates :file_name, presence: true
  validates :file_size, numericality: { greater_than: 0, allow_nil: true }

  # File type categories
  DOCUMENT_TYPES = %w[pdf doc docx txt].freeze
  IMAGE_TYPES = %w[jpg jpeg png gif webp].freeze
  VIDEO_TYPES = %w[mp4 avi mov].freeze

  # Scopes
  scope :images, -> { where("file_type IN (?)", IMAGE_TYPES) }
  scope :documents, -> { where("file_type IN (?)", DOCUMENT_TYPES) }
  scope :videos, -> { where("file_type IN (?)", VIDEO_TYPES) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :extract_file_info, if: -> { url.present? && file_name.blank? }

  # Methods
  def image?
    IMAGE_TYPES.include?(file_type&.downcase)
  end

  def document?
    DOCUMENT_TYPES.include?(file_type&.downcase)
  end

  def video?
    VIDEO_TYPES.include?(file_type&.downcase)
  end

  def file_size_human
    return "N/A" unless file_size

    if file_size < 1024
      "#{file_size} B"
    elsif file_size < 1024 * 1024
      "#{(file_size / 1024.0).round(2)} KB"
    else
      "#{(file_size / (1024.0 * 1024)).round(2)} MB"
    end
  end

  private

  def extract_file_info
    return unless url

    uri = URI.parse(url)
    self.file_name = File.basename(uri.path)
    self.file_type = File.extname(file_name).delete(".").downcase
  rescue URI::InvalidURIError
    # Invalid URL, let validation handle it
  end
end
