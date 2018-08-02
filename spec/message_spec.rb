require File.join(File.dirname(__FILE__), 'spec_helper')

describe Txtlocal::Message do
  describe "initialize" do
    let(:new) { Txtlocal::Message.allocate }
    let(:body) { double("body text") }
    let(:recipients) { double("recipients") }
    let(:options) { double("options") }
    before(:each) do
      allow(Txtlocal::Message).to receive(:new) do |*args|
        new.send(:initialize, *args)
      end
    end

    it "should call internal setter methods" do
      expect(new).to receive(:body=).with(body)
      expect(new).to receive(:recipients=).with(recipients)
      expect(new).to receive(:options=).with(options)
      msg = Txtlocal::Message.new(body, recipients, options)
    end
  end

  describe "body text" do
    let(:msg) { Txtlocal::Message.new }
    describe "body" do
      it "should be accessible" do
        msg.body = "body text"
        expect(msg.body).to eq("body text")
      end
      it "should replace newlines with %n" do
        msg.body = "once\nupon\na time"
        expect(msg.body).to eq("once%nupon%na time")
      end
      it "should trim trailing and leading whitespace" do
        msg.body = "  a short message\n\n"
        expect(msg.body).to eq("a short message")
      end
    end
  end

  describe "recipients" do
    let(:msg) { Txtlocal::Message.new }
    describe "accessor" do
      it "should accept single value" do
        msg.recipients = "447729416732"
        expect(msg.recipients).to match(["447729416732"])
      end
      it "should accept multiple values" do
        msg.recipients = ["447729416732", "447923732984"]
        expect(msg.recipients).to match(["447729416732", "447923732984"])
      end
      it "should be using add_recipient internally" do
        expect(msg).to receive(:add_recipient).with("447729416732")
        msg.recipients = "447729416732"
      end
    end
    describe "add_recipient" do
      it "should accept txtlocal format number" do
        msg.add_recipient("447729416732")
        expect(msg.recipients).to match(["447729416732"])
      end
      it "should accept 07 format number" do
        msg.add_recipient("07729416745")
        expect(msg.recipients).to match(["447729416745"])
      end
      it "should accept international format number" do
        msg.add_recipient("+447729416745")
        expect(msg.recipients).to match(["447729416745"])
      end
      it "should accept numbers with spaces" do
        msg.add_recipient("07729 457 756")
        expect(msg.recipients).to match(["447729457756"])
      end
      it "should not add invalid numbers" do
        # TODO: exception here?
        msg.add_recipient("qwdcs")
        msg.add_recipient("0114 245 9832")
        msg.add_recipient("0800 800 8000")
        expect(msg.recipients).to be_empty
      end
    end
  end

  describe "from" do
    let(:msg) { Txtlocal::Message.new }
    before(:each) do
      Txtlocal.config.from = "default"
    end
    after(:each) do
      Txtlocal.reset_config
    end
    it "should default to config.from" do
      expect(msg.from).to eq("default")
    end
    it "should be overridable" do
      msg.from = "overridden"
      expect(msg.from).to eq("overridden")
    end
    it "should revert to default if set to nil" do
      msg.from = "overridden"
      expect(msg.from).to eq("overridden")
      msg.from = nil
      expect(msg.from).to eq("default")
    end
    it "should truncate if set to longer than 11 characters" do
      msg.from = "123456789012345"
      expect(msg.from).to eq("12345678901")
    end
    it "should fail silently if set to less than 3 characters" do
      msg.from = "12"
      expect(msg.from).to eq("default")
    end
    it "should trim whitespace and remove any non alphanumeric or space characters" do
      msg.from = " a person! "
      expect(msg.from).to eq("a person")
    end
  end

  describe "options" do
    let(:msg) { Txtlocal::Message.new }
    it "should accept :from" do
      msg.options = {:from => "my name"}
      expect(msg.from).to eq("my name")
    end
  end

  describe "send!" do
    context "web mocked" do
      context "username and password authentication" do
        before(:each) do
          WebMock.disable_net_connect!
          stub_request(:post, "https://www.txtlocal.com/sendsmspost.php")
          Txtlocal.config do |c|
            c.from = "testing"
            c.username = "testuser"
            c.password = "testpass"
            c.test = false
          end
        end
        after(:each) do
          Txtlocal.reset_config
        end
        it "should send data to the API endpoint" do
          msg = Txtlocal::Message.new("a message", "447729416583")
          msg.send!
          expect(WebMock).to have_requested(:post, "https://www.txtlocal.com/sendsmspost.php").with(
            body: {'uname' => "testuser", 'pword' => "testpass", 'json' => '1', 'test' => '0',
                   'from' => "testing", 'selectednums' => "447729416583", 'message' => "a message"}
          )
        end
        it "should comma sepratate multiple recipients" do
          msg = Txtlocal::Message.new("a message", ["447729416583", "447984534657"])
          msg.send!
          expect(WebMock).to have_requested(:post, "https://www.txtlocal.com/sendsmspost.php").with(
            body: {'uname' => "testuser", 'pword' => "testpass", 'json' => '1', 'test' => '0',
                   'from' => "testing", 'selectednums' => "447729416583,447984534657",
                   'message' => "a message"}
          )
        end
      end
      context "api key authentication" do
        before(:each) do
          WebMock.disable_net_connect!
          stub_request(:post, "https://www.txtlocal.com/sendsmspost.php")
          Txtlocal.config do |c|
            c.from = "testing"
            c.api_key = "testapikey"
            c.test = false
          end
        end
        after(:each) do
          Txtlocal.reset_config
        end
        it "should send data to the API endpoint" do
          msg = Txtlocal::Message.new("a message", "447729416583")
          msg.send!
          expect(WebMock).to have_requested(:post, "https://www.txtlocal.com/sendsmspost.php").with(
            body: {'apikey' => "testapikey", 'json' => '1', 'test' => '0',
                   'from' => "testing", 'selectednums' => "447729416583", 'message' => "a message"}
          )
        end
      end
    end
    context "api test mode" do
      if not (File.readable?('api_login.rb') and load('api_login.rb') and
              API_USERNAME and API_PASSWORD)
        pending "\n" +
          "Please create a file api_login.rb that defines API_USERNAME and API_PASSWORD " +
          "to run tests against the real server"
      else
        before(:each) do
          WebMock.allow_net_connect!
          Txtlocal.config do |c|
            c.from = "testing"
            c.username = API_USERNAME
            c.password = API_PASSWORD
            c.test = true
          end
        end
        it "should send data to the API endpoint" do
          msg = Txtlocal::Message.new("a message", "447729467413")
          msg.send!
          expect(msg.response).not_to be_nil
          expect(msg.response[:error]).to include("testmode")
        end
      end
    end
  end
end
