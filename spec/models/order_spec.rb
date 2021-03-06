require 'rails_helper'

describe Order, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe "relationships" do
    it {should belong_to :user}
    it {should have_many :item_orders}
    it {should have_many(:items).through(:item_orders)}
  end

  describe 'instance methods' do
    before :each do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)

      @user = User.create!(name: 'Billy Joel',
                          address: '123 Song St.',
                          city: 'Las Vegas',
                          state: 'NV',
                          zip: '12345',
                          email: 'billy_j@user.com',
                          password: '123',
                          role: 0)

      @order_1 = @user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)

      @io1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      @io2 = @order_1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3)
    end

    it 'grandtotal' do
      expect(@order_1.grandtotal).to eq(230)
    end

    it 'total_quantity' do
      expect(@order_1.total_quantity).to eq(5)
    end

    it "change_status_cancel" do
      @order_1.change_status_cancel
      expect(@order_1.order_status).to eq("cancelled")
    end

    it 'change_status_packaged' do
      @io1.update_attribute(:order_status, "fulfilled")
      @io2.update_attribute(:order_status, "fulfilled")
      @order_1.change_status_packaged
      expect(@order_1.order_status).to eq('packaged')
    end

    it 'merchant_items' do
      expect(@order_1.merchant_items(@meg.id).length).to eq(1)
      expect(@order_1.merchant_items(@meg.id).first.id).to eq(@tire.id)
      expect(@order_1.merchant_items(@meg.id).first.name).to eq(@tire.name)
      expect(@order_1.merchant_items(@meg.id).first.image).to eq(@tire.image)
      expect(@order_1.merchant_items(@meg.id).first.price).to eq(@tire.price)
      expect(@order_1.merchant_items(@meg.id).first.inventory).to eq(@tire.inventory)
      expect(@order_1.merchant_items(@meg.id).first.order_status).to eq(@io1.order_status)
      expect(@order_1.merchant_items(@meg.id).first.quantity).to eq(@io1.quantity)
      expect(@order_1.merchant_items(@meg.id).first.io_id).to eq(@io1.id)
    end

    it 'return_item_quantities' do
      expect(@tire.inventory).to eq(12)
      @order_1.return_item_quantities
    end
  end
end
