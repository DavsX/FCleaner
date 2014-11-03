require_relative 'FCleaner/version'
require 'mechanize'

module FCleaner
  FACEBOOK_URL = 'https://m.facebook.com'
  PROFILE_URL = "#{FACEBOOK_URL}/profile"
  ACTIVITY_LOG_URL_TEXT = 'Activity Log'

  def self.init(mail, pass)
    @mail = mail
    @pass = pass
    @mech = Mechanize.new { |agent| agent.user_agent_alias = 'iPhone' }
  end

  def self.get_user_id()
    @profile_page ||= @mech.get(PROFILE_URL)
    link = @profile_page.links_with(:text => ACTIVITY_LOG_URL_TEXT).first
    @user_id = link.href.gsub(/^#{FACEBOOK_URL}\//,'').gsub(/\/.*$/, '')
  end

  def self.get_registration_year()
    page = @mech.get(activity_log_url)
    year_links = page.parser.xpath("//div[@id[starts-with(.,'year_')]]")
    reg_year = year_links.collect do |x|
      x.attribute('id').to_s.gsub(/^year_/, '')
    end.min

    if reg_year
      reg_year
    else
      Date.today.year
    end
  end

  def self.activity_log_url()
    "#{FACEBOOK_URL}/#{@user_id}/allactivity"
  end
end

#search_form = page.form
#search_form.field_with(:name => 'email').value = 'davserer@gmail.com'
#search_form.field_with(:name => 'pass').value = 'mypassword'

#new_page = agent.submit search_form

#puts new_page
