# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime
#  jti        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti)
#

require "rails_helper"

RSpec.describe JwtDenylist, type: :model do
  describe "table structure" do
    it "has expected columns" do
      expect(JwtDenylist.column_names).to include("jti", "exp", "created_at", "updated_at")
    end

    it "has index on jti column" do
      indexes = ActiveRecord::Base.connection.indexes(:jwt_denylists)
      jti_index = indexes.find { |idx| idx.columns == [ "jti" ] }
      expect(jti_index).to be_present
    end
  end

  describe "creating denylist entry" do
    it "creates a valid entry with jti and exp" do
      jwt_entry = JwtDenylist.create!(
        jti: SecureRandom.uuid,
        exp: 24.hours.from_now
      )

      expect(jwt_entry).to be_persisted
      expect(jwt_entry.jti).to be_present
      expect(jwt_entry.exp).to be_present
    end

    it "allows multiple entries with different jtis" do
      JwtDenylist.create!(jti: SecureRandom.uuid, exp: 1.hour.from_now)
      JwtDenylist.create!(jti: SecureRandom.uuid, exp: 2.hours.from_now)

      expect(JwtDenylist.count).to eq(2)
    end
  end

  describe "finding denylisted tokens" do
    let!(:denylisted_token) { JwtDenylist.create!(jti: "test-jti-123", exp: 1.hour.from_now) }

    it "finds token by jti" do
      found = JwtDenylist.find_by(jti: "test-jti-123")
      expect(found).to eq(denylisted_token)
    end

    it "returns nil for non-denylisted jti" do
      found = JwtDenylist.find_by(jti: "non-existent-jti")
      expect(found).to be_nil
    end
  end

  describe "expiration handling" do
    it "stores expiration timestamp" do
      future_time = 2.days.from_now
      jwt_entry = JwtDenylist.create!(jti: SecureRandom.uuid, exp: future_time)

      expect(jwt_entry.exp).to be_within(1.second).of(future_time)
    end

    it "can query expired tokens" do
      expired_token = JwtDenylist.create!(jti: "expired-123", exp: 1.hour.ago)
      valid_token = JwtDenylist.create!(jti: "valid-456", exp: 1.hour.from_now)

      expired = JwtDenylist.where("exp < ?", Time.current)
      expect(expired).to include(expired_token)
      expect(expired).not_to include(valid_token)
    end
  end
end
