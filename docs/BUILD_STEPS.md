# ShopHub - Покрокова Інструкція Побудови

E-commerce платформа: Rails API (backend) + React (frontend)

---

## 📋 Зміст

1. [Підготовка та Ініціалізація](#крок-1-підготовка-та-ініціалізація)
2. [Створення Rails API](#крок-2-створення-rails-api)
3. [Налаштування PostgreSQL](#крок-3-налаштування-postgresql)
4. [Створення Моделей](#крок-4-створення-моделей)
5. [Контролери та Routes](#крок-5-контролери-та-routes)
6. [Аутентифікація та Авторизація](#крок-6-аутентифікація-та-авторизація)
7. [Тестування з RSpec](#крок-7-тестування-з-rspec)
8. [React Frontend](#крок-8-react-frontend)
9. [Деплой та Оптимізація](#крок-9-деплой-та-оптимізація)

---

## Крок 1: Підготовка та Ініціалізація

### 1.1 Перевірка версій

```bash
ruby -v        # Ruby 3.2+
rails -v       # Rails 7.1+
postgres --version
node -v        # Node 18+
git --version
```

### 1.2 Створення Rails API проєкту

```bash
cd /Users/vkuzm/RubymineProjects/shop_hub

# Створити Rails API (тільки backend, без views)
rails new . --api --database=postgresql --skip-test

# Або якщо директорія вже існує:
rails new backend --api --database=postgresql --skip-test
```

### 1.3 Налаштування Git

```bash
git init
git add .
git commit -m "Initial commit: Rails API setup"
```

### 1.4 Встановлення основних gems

**Gemfile:**
```ruby
# Core
gem "rails", "~> 7.1"
gem "pg", "~> 1.5"
gem "puma", "~> 6.0"

# API
gem "rack-cors"        # CORS для React frontend
gem "fast_jsonapi"     # Швидка JSON serialization
gem "kaminari"         # Pagination

# Authentication
gem "devise"
gem "devise-jwt"       # JWT authentication
gem "pundit"           # Authorization

# Background jobs
gem "sidekiq"

group :development, :test do
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "rubocop-rails", require: false
end

group :test do
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end
```

**Встановити gems:**
```bash
bundle install
```

---

## Крок 2: Створення Rails API

### 2.1 Структура проєкту

```
shop_hub/
├── backend/              # Rails API
│   ├── app/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── serializers/
│   │   ├── services/     # Business logic
│   │   └── policies/     # Authorization
│   ├── config/
│   ├── db/
│   └── spec/
└── frontend/             # React (створимо пізніше)
```

### 2.2 Налаштування CORS

**config/initializers/cors.rb:**
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3000", "localhost:5173" # React dev server

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

---

## Крок 3: Налаштування PostgreSQL

### 3.1 Створення бази даних

**config/database.yml:**
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: localhost

development:
  <<: *default
  database: shop_hub_development

test:
  <<: *default
  database: shop_hub_test

production:
  <<: *default
  database: shop_hub_production
```

**Створити БД:**
```bash
rails db:create
rails db:migrate
```

---

## Крок 4: Створення Моделей

### 4.1 Основні моделі (ActiveRecord)

#### **User** (Покупець/Адмін)
```bash
rails g model User email:string:uniq password_digest:string role:integer first_name:string last_name:string
```

**app/models/user.rb:**
```ruby
class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  
  # Enums (використання Ruby enum)
  enum role: { customer: 0, admin: 1 }
  
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  
  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }
  
  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

#### **Product** (Товар)
```bash
rails g model Product name:string description:text price:decimal stock:integer category_id:integer sku:string:uniq active:boolean
```

**app/models/product.rb:**
```ruby
class Product < ApplicationRecord
  # Associations
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :reviews, dependent: :destroy
  has_many_attached :images  # ActiveStorage для зображень
  
  # Validations
  validates :name, :price, :stock, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_nil: true
  
  # Scopes (ActiveRecord query interface)
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :search, ->(query) { where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }
  
  # Callbacks (Ruby blocks)
  before_save :generate_sku, if: -> { sku.blank? }
  
  # Methods
  def in_stock?
    stock > 0
  end
  
  def average_rating
    reviews.average(:rating).to_f.round(2)
  end
  
  private
  
  def generate_sku
    self.sku = "PROD-#{SecureRandom.hex(4).upcase}"
  end
end
```

#### **Category** (Категорія)
```bash
rails g model Category name:string:uniq description:text parent_id:integer position:integer
```

**app/models/category.rb:**
```ruby
class Category < ApplicationRecord
  # Self-referential association (вкладені категорії)
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  has_many :products, dependent: :destroy
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  
  # Scopes
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(position: :asc) }
  
  # Methods
  def subcategories
    children
  end
  
  def all_products
    # Рекурсивно отримати всі продукти з підкатегорій
    Product.where(category_id: descendant_ids + [id])
  end
  
  private
  
  def descendant_ids
    children.flat_map { |child| [child.id] + child.descendant_ids }
  end
end
```

#### **Order** (Замовлення)
```bash
rails g model Order user:references total_amount:decimal status:integer
```

**app/models/order.rb:**
```ruby
class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  # Enums
  enum status: { 
    pending: 0, 
    confirmed: 1, 
    shipped: 2, 
    delivered: 3, 
    cancelled: 4 
  }
  
  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  
  # Callbacks
  before_create :calculate_total
  after_create :send_confirmation_email
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  
  private
  
  def calculate_total
    self.total_amount = order_items.sum { |item| item.quantity * item.price }
  end
  
  def send_confirmation_email
    # OrderMailer.confirmation(self).deliver_later
  end
end
```

#### **OrderItem** (Позиції замовлення)
```bash
rails g model OrderItem order:references product:references quantity:integer price:decimal
```

**app/models/order_item.rb:**
```ruby
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  
  # Callback: зберегти поточну ціну продукту
  before_validation :set_price, on: :create
  
  private
  
  def set_price
    self.price = product.price if price.nil?
  end
end
```

#### **Review** (Відгуки)
```bash
rails g model Review user:references product:references rating:integer comment:text
```

**app/models/review.rb:**
```ruby
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "can only review a product once" }
  
  # Counter cache
  after_create :update_product_rating
  after_destroy :update_product_rating
  
  private
  
  def update_product_rating
    product.update(average_rating: product.reviews.average(:rating))
  end
end
```

### 4.2 Міграції

```bash
rails db:migrate
```

---

## Крок 5: Контролери та Routes

### 5.1 API Versioning (Rails routing)

**config/routes.rb:**
```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication
      post "/signup", to: "auth#signup"
      post "/login", to: "auth#login"
      delete "/logout", to: "auth#logout"
      
      # Resources (RESTful routes)
      resources :products do
        resources :reviews, only: [:index, :create]
        
        collection do
          get :search
          get :featured
        end
      end
      
      resources :categories do
        member do
          get :products
        end
      end
      
      resources :orders, only: [:index, :show, :create, :update] do
        member do
          patch :cancel
        end
      end
      
      # Cart
      resource :cart, only: [] do
        post :add_item
        delete :remove_item
        patch :update_quantity
        get :items
        delete :clear
      end
      
      # Admin routes
      namespace :admin do
        resources :products
        resources :categories
        resources :orders, only: [:index, :show, :update]
        resources :users, only: [:index, :show]
      end
    end
  end
end
```

### 5.2 Base Controller (з модулями)

**app/controllers/api/v1/base_controller.rb:**
```ruby
module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable      # Custom module для auth
      include ExceptionHandler   # Custom module для errors
      include Paginable          # Custom module для pagination
      
      before_action :authenticate_user!
      
      private
      
      def current_user
        @current_user ||= User.find_by(id: decoded_token["user_id"])
      end
    end
  end
end
```

### 5.3 Products Controller

**app/controllers/api/v1/products_controller.rb:**
```ruby
module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :search]
      
      # GET /api/v1/products
      def index
        @products = Product.active
                           .includes(:category, :reviews)
                           .page(params[:page])
                           .per(params[:per_page] || 20)
        
        render json: ProductSerializer.new(@products, {
          include: [:category],
          meta: pagination_meta(@products)
        }).serializable_hash
      end
      
      # GET /api/v1/products/:id
      def show
        @product = Product.includes(:category, reviews: :user).find(params[:id])
        
        render json: ProductSerializer.new(@product, {
          include: [:category, :reviews]
        }).serializable_hash
      end
      
      # POST /api/v1/products (admin only)
      def create
        authorize Product  # Pundit authorization
        
        @product = Product.new(product_params)
        
        if @product.save
          render json: ProductSerializer.new(@product).serializable_hash, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])
        authorize @product
        
        if @product.update(product_params)
          render json: ProductSerializer.new(@product).serializable_hash
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/products/:id
      def destroy
        @product = Product.find(params[:id])
        authorize @product
        
        @product.destroy
        head :no_content
      end
      
      # GET /api/v1/products/search
      def search
        @products = Product.active
                           .search(params[:q])
                           .page(params[:page])
        
        render json: ProductSerializer.new(@products).serializable_hash
      end
      
      private
      
      # Strong parameters (Rails security)
      def product_params
        params.require(:product).permit(
          :name, :description, :price, :stock, :category_id, :sku, :active, images: []
        )
      end
    end
  end
end
```

### 5.4 Orders Controller

**app/controllers/api/v1/orders_controller.rb:**
```ruby
module Api
  module V1
    class OrdersController < BaseController
      # GET /api/v1/orders
      def index
        @orders = current_user.orders.includes(:order_items).recent
        
        render json: OrderSerializer.new(@orders, {
          include: [:order_items]
        }).serializable_hash
      end
      
      # GET /api/v1/orders/:id
      def show
        @order = current_user.orders.includes(order_items: :product).find(params[:id])
        
        render json: OrderSerializer.new(@order, {
          include: [:order_items, "order_items.product"]
        }).serializable_hash
      end
      
      # POST /api/v1/orders
      def create
        # Використати Service Object для складної бізнес-логіки
        result = Orders::CreateService.call(
          user: current_user,
          items: params[:items]
        )
        
        if result.success?
          render json: OrderSerializer.new(result.order).serializable_hash, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
      
      # PATCH /api/v1/orders/:id/cancel
      def cancel
        @order = current_user.orders.find(params[:id])
        
        if @order.pending? && @order.update(status: :cancelled)
          render json: OrderSerializer.new(@order).serializable_hash
        else
          render json: { error: "Cannot cancel this order" }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

---

## Крок 6: Аутентифікація та Авторизація

### 6.1 JWT Authentication

**app/controllers/concerns/authenticable.rb** (Module):
```ruby
module Authenticable
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_user!
  end
  
  private
  
  def authenticate_user!
    token = extract_token_from_header
    
    unless token && valid_token?(token)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
  
  def current_user
    @current_user ||= User.find_by(id: decoded_token["user_id"])
  end
  
  def extract_token_from_header
    request.headers["Authorization"]&.split(" ")&.last
  end
  
  def valid_token?(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
    @decoded_token = decoded.first
    true
  rescue JWT::DecodeError
    false
  end
  
  def decoded_token
    @decoded_token
  end
end
```

### 6.2 Pundit Authorization (Policies)

**app/policies/product_policy.rb:**
```ruby
class ProductPolicy < ApplicationPolicy
  # Модуль для authorization logic
  
  def index?
    true  # Всі можуть переглядати
  end
  
  def show?
    true
  end
  
  def create?
    user&.admin?
  end
  
  def update?
    user&.admin?
  end
  
  def destroy?
    user&.admin?
  end
  
  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.active
      end
    end
  end
end
```

---

## Крок 7: Тестування з RSpec

### 7.1 Налаштування RSpec

```bash
rails generate rspec:install
```

**spec/rails_helper.rb:**
```ruby
require "spec_helper"
require "rspec/rails"
require "database_cleaner/active_record"

RSpec.configure do |config|
  # FactoryBot
  config.include FactoryBot::SyntaxMethods
  
  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end
  
  # Shoulda Matchers
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
```

### 7.2 Factories (FactoryBot)

**spec/factories/users.rb:**
```ruby
FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    role { :customer }
    
    trait :admin do
      role { :admin }
    end
  end
end
```

**spec/factories/products.rb:**
```ruby
FactoryBot.define do
  factory :product do
    association :category
    
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..500.0) }
    stock { rand(0..100) }
    sku { Faker::Code.unique.asin }
    active { true }
    
    trait :out_of_stock do
      stock { 0 }
    end
    
    trait :inactive do
      active { false }
    end
  end
end
```

### 7.3 Model Specs (ActiveRecord тести)

**spec/models/product_spec.rb:**
```ruby
require "rails_helper"

RSpec.describe Product, type: :model do
  # Association tests (shoulda-matchers)
  describe "associations" do
    it { should belong_to(:category) }
    it { should have_many(:order_items) }
    it { should have_many(:reviews) }
  end
  
  # Validation tests
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_uniqueness_of(:sku) }
  end
  
  # Scope tests
  describe "scopes" do
    let!(:active_product) { create(:product, active: true) }
    let!(:inactive_product) { create(:product, active: false) }
    
    it "returns only active products" do
      expect(Product.active).to include(active_product)
      expect(Product.active).not_to include(inactive_product)
    end
    
    it "returns only in-stock products" do
      in_stock = create(:product, stock: 10)
      out_of_stock = create(:product, :out_of_stock)
      
      expect(Product.in_stock).to include(in_stock)
      expect(Product.in_stock).not_to include(out_of_stock)
    end
  end
  
  # Method tests
  describe "#in_stock?" do
    it "returns true when stock > 0" do
      product = create(:product, stock: 5)
      expect(product.in_stock?).to be true
    end
    
    it "returns false when stock = 0" do
      product = create(:product, :out_of_stock)
      expect(product.in_stock?).to be false
    end
  end
  
  describe "#average_rating" do
    let(:product) { create(:product) }
    
    it "calculates average rating from reviews" do
      create(:review, product: product, rating: 4)
      create(:review, product: product, rating: 5)
      
      expect(product.average_rating).to eq(4.5)
    end
  end
end
```

### 7.4 Controller Specs

**spec/controllers/api/v1/products_controller_spec.rb:**
```ruby
require "rails_helper"

RSpec.describe Api::V1::ProductsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  
  describe "GET #index" do
    it "returns list of products" do
      products = create_list(:product, 3)
      
      get :index
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
    end
    
    it "paginates results" do
      create_list(:product, 25)
      
      get :index, params: { page: 1, per_page: 10 }
      
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(10)
    end
  end
  
  describe "POST #create" do
    context "as admin" do
      before { sign_in admin }
      
      it "creates a new product" do
        category = create(:category)
        product_params = attributes_for(:product, category_id: category.id)
        
        expect {
          post :create, params: { product: product_params }
        }.to change(Product, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
    end
    
    context "as customer" do
      before { sign_in user }
      
      it "denies access" do
        post :create, params: { product: attributes_for(:product) }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

---

## Крок 8: Service Objects (Ruby ООП)

### 8.1 Order Creation Service

**app/services/orders/create_service.rb:**
```ruby
module Orders
  class CreateService
    # Service Object pattern для складної бізнес-логіки
    
    attr_reader :user, :items, :order, :errors
    
    def initialize(user:, items:)
      @user = user
      @items = items
      @errors = []
    end
    
    # Class method для виклику
    def self.call(user:, items:)
      new(user: user, items: items).call
    end
    
    def call
      ActiveRecord::Base.transaction do
        validate_items!
        create_order!
        create_order_items!
        update_stock!
        send_notifications!
      end
      
      self
    rescue StandardError => e
      @errors << e.message
      self
    end
    
    def success?
      errors.empty?
    end
    
    private
    
    def validate_items!
      raise "No items provided" if items.blank?
      
      items.each do |item|
        product = Product.find(item[:product_id])
        raise "#{product.name} is out of stock" unless product.stock >= item[:quantity]
      end
    end
    
    def create_order!
      @order = user.orders.create!(status: :pending)
    end
    
    def create_order_items!
      items.each do |item|
        product = Product.find(item[:product_id])
        
        @order.order_items.create!(
          product: product,
          quantity: item[:quantity],
          price: product.price
        )
      end
    end
    
    def update_stock!
      items.each do |item|
        product = Product.find(item[:product_id])
        product.decrement!(:stock, item[:quantity])
      end
    end
    
    def send_notifications!
      # Sidekiq background job
      OrderConfirmationJob.perform_later(@order.id)
    end
  end
end
```

---

## Крок 9: Serializers (JSON API)

**app/serializers/product_serializer.rb:**
```ruby
class ProductSerializer
  include JSONAPI::Serializer
  
  attributes :name, :description, :price, :stock, :sku, :active, :average_rating
  
  belongs_to :category
  has_many :reviews
  
  # Custom attributes (Ruby блоки)
  attribute :in_stock do |product|
    product.in_stock?
  end
  
  attribute :image_urls do |product|
    product.images.map { |img| Rails.application.routes.url_helpers.url_for(img) }
  end
  
  # Conditional attributes
  attribute :admin_info, if: Proc.new { |record, params|
    params && params[:current_user]&.admin?
  } do |product|
    {
      cost: product.cost,
      margin: product.margin
    }
  end
end
```

---

## Крок 10: Background Jobs (Sidekiq)

**app/jobs/order_confirmation_job.rb:**
```ruby
class OrderConfirmationJob < ApplicationJob
  queue_as :default
  
  def perform(order_id)
    order = Order.includes(:user, order_items: :product).find(order_id)
    
    # Send email
    OrderMailer.confirmation(order).deliver_now
    
    # Log to analytics
    AnalyticsService.track_order(order)
  end
end
```

---

## Крок 11: Seeds (тестові дані)

**db/seeds.rb:**
```ruby
# Використання Ruby блоків та ітераторів

puts "🌱 Seeding database..."

# Clear existing data
[User, Product, Category, Order, Review].each(&:destroy_all)

# Create admin user
admin = User.create!(
  email: "admin@shophub.com",
  password: "password",
  first_name: "Admin",
  last_name: "User",
  role: :admin
)

# Create categories (з ієрархією)
electronics = Category.create!(name: "Electronics", description: "Electronic devices")
phones = Category.create!(name: "Phones", parent: electronics, description: "Mobile phones")
laptops = Category.create!(name: "Laptops", parent: electronics, description: "Laptop computers")

clothing = Category.create!(name: "Clothing", description: "Apparel")
mens = Category.create!(name: "Men's", parent: clothing)
womens = Category.create!(name: "Women's", parent: clothing)

# Create products (з блоками)
10.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10.0..500.0),
    stock: rand(0..100),
    category: [phones, laptops, mens, womens].sample,
    active: true
  )
end

# Create customers and orders
5.times do
  customer = User.create!(
    email: Faker::Internet.email,
    password: "password",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: :customer
  )
  
  # Create orders for each customer
  rand(1..3).times do
    order = customer.orders.create!(
      status: [:pending, :confirmed, :shipped].sample,
      total_amount: 0
    )
    
    # Add items to order
    rand(1..5).times do
      product = Product.active.sample
      order.order_items.create!(
        product: product,
        quantity: rand(1..3),
        price: product.price
      )
    end
    
    # Update total
    order.update!(total_amount: order.order_items.sum { |item| item.price * item.quantity })
  end
end

puts "✅ Seeding complete!"
puts "   Users: #{User.count} (#{User.admins.count} admins)"
puts "   Categories: #{Category.count}"
puts "   Products: #{Product.count}"
puts "   Orders: #{Order.count}"
```

**Запустити seeds:**
```bash
rails db:seed
```

---

## Крок 12: React Frontend

### 12.1 Створення React app

```bash
# В корені проєкту
npm create vite@latest frontend -- --template react-ts
cd frontend
npm install

# Встановити додаткові пакети
npm install axios react-router-dom @tanstack/react-query
npm install -D tailwindcss postcss autoprefixer
```

### 12.2 API Client (TypeScript)

**frontend/src/api/client.ts:**
```typescript
import axios from 'axios';

const API_URL = 'http://localhost:3000/api/v1';

export const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor для JWT token
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Products API
export const productsApi = {
  getAll: (params?: { page?: number; per_page?: number }) => 
    apiClient.get('/products', { params }),
  
  getOne: (id: number) => 
    apiClient.get(`/products/${id}`),
  
  search: (query: string) => 
    apiClient.get('/products/search', { params: { q: query } }),
};

// Orders API
export const ordersApi = {
  create: (items: Array<{ product_id: number; quantity: number }>) =>
    apiClient.post('/orders', { items }),
  
  getAll: () => 
    apiClient.get('/orders'),
};
```

---

## Крок 13: Запуск та Тестування

### 13.1 Запустити Rails сервер

```bash
# Terminal 1: Rails API
cd backend
rails server -p 3000
```

### 13.2 Запустити React dev server

```bash
# Terminal 2: React frontend
cd frontend
npm run dev
```

### 13.3 Запустити тести

```bash
# RSpec тести
bundle exec rspec

# З coverage
bundle exec rspec --format documentation

# Конкретний файл
bundle exec rspec spec/models/product_spec.rb

# RuboCop (linter)
bundle exec rubocop

# Auto-fix
bundle exec rubocop -a
```

---

## 📚 Концепти що використовуються:

### **Ruby:**
- ✅ **Синтаксис**: blocks `{ }`, lambdas `->`, symbols `:symbol`
- ✅ **ООП**: класи, модулі, наслідування, mixins
- ✅ **Блоки**: `each`, `map`, `select`, `reduce`, `yield`
- ✅ **Модулі**: `Authenticable`, `Paginable`, `OrdersService`

### **Rails:**
- ✅ **MVC**: Models (ActiveRecord), Controllers (API), Views (JSON)
- ✅ **Маршрутизація**: `resources`, `namespace`, nested routes
- ✅ **ActiveRecord**: associations, validations, callbacks, scopes
- ✅ **ActiveSupport**: Concerns, `included`, `class_methods`

### **Інструменти:**
- ✅ **Git**: version control, commits, branches
- ✅ **PostgreSQL**: relational DB, migrations, indexes
- ✅ **RSpec**: model specs, controller specs, factories
- ✅ **Gems**: bundler, devise, pundit, sidekiq

---

## 🚀 Наступні кроки:

1. **Почати з проєкту** - виконати Крок 1-2
2. **Створити моделі** - Крок 4
3. **Налаштувати API** - Крок 5
4. **Додати тести** - Крок 7
5. **React інтеграція** - Крок 8

**Готовий розпочати побудову?** 🎯
