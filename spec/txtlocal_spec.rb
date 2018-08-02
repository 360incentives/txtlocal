require File.join(File.dirname(__FILE__), 'spec_helper')

describe Txtlocal do

  describe "config" do
    it "should be accessible" do
      expect(Txtlocal.config.class).to eq(Txtlocal::Config)
    end

    it "should be modifiable with a block" do
      remember = nil
      Txtlocal.config do |c|
        expect(c.class).to eq(Txtlocal::Config)
        remember = c
      end
      expect(Txtlocal.config).to eq(remember)
    end

    it "should be resettable" do
      c = Txtlocal.config
      Txtlocal.reset_config
      expect(Txtlocal.config).not_to eq(c)
    end
  end

  describe "send_message" do
    let(:message)      { double("message body") }
    let(:recipients)   { double("list of recipients") }
    let(:options)      { double("additional message options") }
    let(:msg_instance) { double("message instance") }

    it "should construct a Message instance and send! it" do
      expect(msg_instance).to receive(:send!).with(no_args)
      expect(Txtlocal::Message).to receive(:new).with(message, recipients, options).and_return(msg_instance)
      expect(Txtlocal.send_message(message, recipients, options)).to eq(msg_instance)
    end
  end

end
