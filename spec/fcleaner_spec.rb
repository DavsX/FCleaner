require_relative 'spec_helper'

describe "FCleaner/ActivityLog" do
  before :each do
    @alog = FCleaner::ActivityLog.new 'myemail', 'mypass'
  end

  after :each do
    FakeWeb.clean_registry
  end

  describe "#initialize" do
    it "stores email and password" do
      expect(@alog.email).to eq('myemail')
      expect(@alog.pass).to eq('mypass')
    end
  end

  describe "#login" do
    before :each do
      @homepage_html ||= File.read('spec/mock_html/homepage_login.html')

      FakeWeb.register_uri(:get, FCleaner::HOMEPAGE_URL,
                           :body => @homepage_html,
                           :content_type => 'text/html')
    end

    it "should log in successfully when credentials are good" do
      FakeWeb.register_uri(:post, %r/#{FCleaner::LOGIN_URL}/, :body => 'test')

      expect { @alog.login }.not_to raise_error

      expect(FakeWeb.last_request.path).to match(%r'^/login.php')
      expect(FakeWeb.last_request.method).to eq('POST')
      expect(FakeWeb.last_request.body).to match("email=#{@alog.email}")
      expect(FakeWeb.last_request.body).to match("pass=#{@alog.pass}")
    end

    it "should die when given wrong credentials" do
      FakeWeb.register_uri(:post, %r/#{FCleaner::LOGIN_URL}/,
                           :body => 'Your password was incorrect.')

      expect { @alog.login }.to raise_error(FCleaner::InvalidLoginCredentials)

      expect(FakeWeb.last_request.path).to match(%r'^/login.php')
      expect(FakeWeb.last_request.method).to eq('POST')
      expect(FakeWeb.last_request.body).to match("email=#{@alog.email}")
      expect(FakeWeb.last_request.body).to match("pass=#{@alog.pass}")
    end
  end

  describe "#user_id" do
    it 'should get the user id' do
      html = File.read('spec/mock_html/profile.html')
      FakeWeb.register_uri( :get, FCleaner::PROFILE_URL,
                            :body => html,
                            :content_type => 'text/html')

      expect(@alog.user_id).to eq("100008460938593")

      FakeWeb.clean_registry
    end
  end

  describe "#reg_year" do
    before :each do
      @alog.instance_variable_set(:@user_id, 123456)
    end

    it 'succeeds when the user is registered for more than a year' do
      html = File.read('spec/mock_html/allactivity_reg_date.html')
      FakeWeb.register_uri( :get, "https://m.facebook.com/123456/allactivity",
                            :body => html,
                            :content_type => 'text/html')

      expect(@alog.reg_year).to eq("2008")

      FakeWeb.clean_registry
    end

    it 'succeeds when the user is registered for less than a year' do
      html = File.read('spec/mock_html/activity_log.html')
      FakeWeb.register_uri( :get, "https://m.facebook.com/123456/allactivity",
                            :body => html,
                            :content_type => 'text/html')

      expect(@alog.reg_year).to eq(Date.today.year)
    end
  end
end
