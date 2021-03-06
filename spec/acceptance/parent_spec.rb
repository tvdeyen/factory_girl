require 'spec_helper'

describe "an instance generated by a factory that inherits from another factory" do
  before do
    define_model("User", :name => :string, :admin => :boolean, :email => :string, :upper_email => :string, :login => :string)

    FactoryGirl.define do
      factory :user do
        name  "John"
        email { "#{name.downcase}@example.com" }
        login { email }

        factory :admin do
          name "admin"
          admin true
          upper_email { email.upcase }
        end

        factory :guest do
          email { "#{name}-guest@example.com" }
        end

        factory :no_email do
          email ""
        end

        factory :bill do
          name  { "Bill" }  #block to make  attribute dynamic
        end
      end
    end
  end

  describe "the parent class" do
    subject     { FactoryGirl.create(:user) }
    it          { should_not be_admin }
    its(:email) { should == "john@example.com" }
  end

  describe "the child class redefining parent's static method used by a dynamic method" do
    subject           { FactoryGirl.create(:admin) }
    it                { should be_kind_of(User) }
    it                { should be_admin }
    its(:name)        { should == "admin" }
    its(:email)       { should == "admin@example.com" }
    its(:upper_email) { should == "ADMIN@EXAMPLE.COM"}
  end

  describe "the child class redefining parent's dynamic method" do
    subject     { FactoryGirl.create(:guest) }
    it          { should_not be_admin }
    its(:name)  { should == "John" }
    its(:email) { should eql "John-guest@example.com" }
    its(:login) { should == "John-guest@example.com" }
  end

  describe "the child class redefining parent's dynamic attribute with static attribute" do
    subject     { FactoryGirl.create(:no_email) }
    its(:email) { should == "" }
  end

  describe "the child class redefining parent's static attribute with dynamic attribute" do
    subject     { FactoryGirl.create(:bill) }
    its(:name)  { should == "Bill" }
  end
end

