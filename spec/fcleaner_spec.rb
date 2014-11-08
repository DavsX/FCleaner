require_relative 'spec_helper'

describe "FCleaner/ActivityLog" do
  before :each do
    @alog = FCleaner::ActivityLog.new 'myemail', 'mypass'
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

      stub_request(:get, FCleaner::HOMEPAGE_URL).to_return(
        :body => @homepage_html, :headers => { "Content-Type" => 'text/html' }
      )
    end

    it "should log in successfully when credentials are good" do
      post_stub = stub_request(:post, %r/#{FCleaner::LOGIN_URL}/).to_return(
        :body => 'test', :headers => { "Content-Type" => 'text/html' }
      )

      expect { @alog.login }.not_to raise_error

      expect(post_stub.with(
          :body => hash_including({ :email => 'myemail', :pass => 'mypass' })
      )).to have_been_requested.once
    end

    it "should die when given wrong credentials" do
      post_stub = stub_request(:post, %r/#{FCleaner::LOGIN_URL}/).to_return(
        :body => 'Your password was incorrect.',
        :headers => { "Content-Type" => 'text/html' }
      )

      expect { @alog.login }.to raise_error(FCleaner::InvalidLoginCredentials)

      expect(post_stub.with(
          :body => hash_including({ :email => 'myemail', :pass => 'mypass' })
      )).to have_been_requested.once
    end
  end

  describe "#user_id" do
    it 'should get the user id' do
      html = File.read('spec/mock_html/profile.html')
      stub_request(:get, FCleaner::PROFILE_URL).to_return(
        :body => html, :headers => { "Content-Type" => 'text/html' }
      )

      expect(@alog.user_id).to eq("100008460938593")
    end
  end

  describe "#reg_year" do
    before :each do
      @alog.instance_variable_set(:@user_id, 123456)
      @url = "https://m.facebook.com/123456/allactivity".freeze
    end

    it 'succeeds when the user is registered for more than a year' do
      html = File.read('spec/mock_html/allactivity_reg_date.html')
      stub_request(:get, @url).to_return(
        :body => html, :headers => { "Content-Type" => 'text/html' }
      )

      expect(@alog.reg_year).to eq("2008")
    end

    it 'succeeds when the user is registered for less than a year' do
      html = File.read('spec/mock_html/activity_log.html')
      stub_request(:get, @url).to_return(
        :body => html, :headers => { "Content-Type" => 'text/html' }
      )

      expect(@alog.reg_year).to eq(Date.today.year)
    end
  end
end
