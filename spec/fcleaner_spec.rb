require_relative 'spec_helper'

describe "FCleaner/ActivityLog" do
  before :each do
    @alog = FCleaner::ActivityLog.new 'myemail', 'mypass'
  end

  describe "VERSION" do
    it 'should not be nil' do
      expect(FCleaner::VERSION).not_to be_nil
    end
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
        :body => html, :headers => { 'Content-Type' => 'text/html' }
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
        :body => html, :headers => { 'Content-Type' => 'text/html' }
      )

      expect(@alog.reg_year).to eq(2008)
    end

    it 'succeeds when the user is registered for less than a year' do
      html = File.read('spec/mock_html/activity_log.html')
      stub_request(:get, @url).to_return(
        :body => html, :headers => { 'Content-Type' => 'text/html' }
      )

      expect(@alog.reg_year).to eq(Date.today.year)
    end
  end

  describe "#clean" do
    it 'should call #clean_month' do
      @alog.instance_variable_set(:@reg_year, 2013)

      allow(Date).to receive(:today).and_return(Date.parse("2014-03-31"))

      1.upto(12).each do |month|
        expect(@alog).to receive(:clean_month).with(2013, month).once
      end
      1.upto(3).each do |month|
        expect(@alog).to receive(:clean_month).with(2014, month).once
      end

      @alog.clean
    end
  end

  describe "#clean_month" do
    it 'opens all the appropriate links' do
      @alog.instance_variable_set(:@user_id, 123456)

      activity_url = 'https://m.facebook.com/123456/allactivity'
      cleanup_url = 'https://m.facebook.com/allactivity/edit'

      stub_request(:get, %r/#{activity_url}/).to_return(
        :body => File.read('spec/mock_html/activity_log.html'),
        :headers => { 'Content-Type' => 'text/html' }
      )
      cleanup_stub = stub_request(:get, %r/#{cleanup_url}/)
                      .to_return(:body => 'Success')

      @alog.clean_month(2014, 10)

      expectations = [
        { 'id' => '1',  'action' => 'hide' },
        { 'id' => '2',  'action' => 'hide' },
        { 'id' => '3',  'action' => 'unlike' },
        { 'id' => '4',  'action' => 'hide' },
        { 'id' => '5',  'action' => 'remove_content' },
        { 'id' => '6',  'action' => 'remove_content' },
        { 'id' => '7',  'action' => 'unlike' },
        { 'id' => '8',  'action' => 'remove_comment' },
        { 'id' => '9',  'action' => 'unlike' },
        { 'id' => '10', 'action' => 'remove_content' },
      ]

      expectations.each do |data|
        expect(cleanup_stub.with( :query => hash_including({
          :id     => data['id'],
          :action => data['action'],
        }))).to have_been_requested.once
      end
    end
  end
end
