require_relative 'FCleaner/version'
require 'mechanize'

module FCleaner
  FACEBOOK_URL = 'https://m.facebook.com'
  PROFILE_URL = "#{FACEBOOK_URL}/profile"
  ACTIVITY_LOG_URL_TEXT = 'Activity Log'

  class Scraper
    def initialize
      @agent = Mechanize.new { |agent| agent.user_agent_alias = 'iPhone' }
    end

    def profile_page
      Page.new @agent.get(PROFILE_URL)
    end

    def activity_log(user_id)
      url = "#{FACEBOOK_URL}/#{user_id}/allactivity"
      Page.new @agent.get(url)
    end
  end

  class Page
    def initialize(page)
      @page = page
    end

    def activity_log_link
      @page.links_with(:text => ACTIVITY_LOG_URL_TEXT).first.href
    end

    def divs_with_id(id)
      @page.parser.xpath("//div[@id[starts-with(.,'#{id}')]]")
    end
  end

  class User
    attr_accessor :mail, :pass, :reg_year, :id

    def initialize(mail, pass)
      @mail = mail
      @pass = pass
    end
  end

  def self.init(mail, pass)
    @user = User.new mail, pass
    @mech = Scraper.new
  end

  def self.get_user_id
    activity_log_link = @mech.profile_page.activity_log_link
    @user.id = activity_log_link.match(%r{/(\d+)/}).captures.first
  end

  def self.get_registration_year
    divs = @mech.activity_log(@user_id).divs_with_id('year_')
    years = divs.collect do |div|
      div.attribute('id').to_s.gsub(/^year_/, '')
    end

    @user.reg_year = if not years.empty?
      years.min
    else
      Date.today.year
    end
  end
end

#search_form = page.form
#search_form.field_with(:name => 'email').value = 'davserer@gmail.com'
#search_form.field_with(:name => 'pass').value = 'mypassword'

#new_page = agent.submit search_form

#puts new_page
