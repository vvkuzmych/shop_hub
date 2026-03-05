require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "confirmation" do
    let(:user) { create(:user, email: "customer@example.com") }
    let(:order) { create(:order, user: user) }
    let(:mail) { OrderMailer.confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order Confirmation ##{order.id} - ShopHub")
      expect(mail.to).to eq([ "customer@example.com" ])
      expect(mail.from).to eq([ "orders@shophub.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Order#confirmation")
    end
  end

  describe "status_update" do
    let(:user) { create(:user, email: "customer@example.com") }
    let(:order) { create(:order, user: user, status: :shipped) }
    let(:mail) { OrderMailer.status_update(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order ##{order.id} - Shipped")
      expect(mail.to).to eq([ "customer@example.com" ])
      expect(mail.from).to eq([ "orders@shophub.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Order#status_update")
    end
  end
end
