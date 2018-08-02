require File.join(File.dirname(__FILE__), 'spec_helper')

describe Txtlocal::Config do
  let(:config) { Txtlocal::Config.new }

  describe "attributes" do
    attributes = %w(test from username password api_key)
    attributes.each do |attr|
      it "should have the '#{attr}' attribute" do
        value = double("value")
        config.send("#{attr}=", value)
        expect(config.send(attr)).to eq(value)
      end
    end
  end

  describe "defaults" do
    defaults = {
      test: false,
      username: nil,
      password: nil,
      from: nil,
      api_key: nil,
    }

    defaults.each_pair do |attr, default|
      example "#{attr} should default to #{default.inspect}" do
        expect(config.send(attr)).to eq(default)
      end
    end
  end

  describe "testing?" do
    it "should return false if test isnt true" do
      expect(config.testing?).to be_falsey
    end
    it "should return true if test is true" do
      config.test = true
      expect(config.testing?).to be_truthy
    end
  end
end
