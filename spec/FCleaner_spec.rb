require_relative 'spec_helper'

describe "FCleaner" do
  before :each do
    FCleaner.init('mail', 'pass')
  end

  it "saves auth data" do
    expect(FCleaner.instance_variable_get :@mail).to eq('mail')
    expect(FCleaner.instance_variable_get :@pass).to eq('pass')
  end

  it "creates mechanizer instance" do
    mech = FCleaner.instance_variable_get :@mech

    expect(mech).to be_an_instance_of(Mechanize)
    expect(mech.user_agent).to match(/iPhone/)
  end

  it "knows profile url" do
    expect(FCleaner::PROFILE_URL).to eq('https://m.facebook.com/profile')
  end

  it "gets user id" do
    html = File.read('spec/mock_html/profile.html')
    FakeWeb.register_uri( :get, FCleaner::PROFILE_URL,
                          :body => html,
                          :content_type => 'text/html')
    expect(FCleaner.get_user_id()).to eq("100008460938593")
  end

  describe "getting registration year" do
    before :each do
      FCleaner.instance_variable_set(:@user_id, '123456')
    end

    it "builds activity log url" do
      url = "https://m.facebook.com/123456/allactivity"
      expect(FCleaner.activity_log_url).to eq(url)
    end

    it "succeeds when user is registered for more than a year" do
      html = File.read('spec/mock_html/allactivity_reg_date.html')
      FakeWeb.register_uri( :get, "https://m.facebook.com/123456/allactivity",
                            :body => html,
                            :content_type => 'text/html')
      expect(FCleaner.get_registration_year()).to eq("2008")
    end

    it "succeeds when user is registered for more than a year" do
      html = File.read('spec/mock_html/allactivity_reg_date_less_than_year.html')
      FakeWeb.register_uri( :get, "https://m.facebook.com/123456/allactivity",
                            :body => html,
                            :content_type => 'text/html')
      expect(FCleaner.get_registration_year()).to eq(Date.today.year)
    end
  end
end
