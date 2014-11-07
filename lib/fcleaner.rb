require 'mechanize'

module FCleaner
  HOMEPAGE_URL = "https://m.facebook.com".freeze
  LOGIN_URL    = "https://m.facebook.com/login.php".freeze
  PROFILE_URL  = "https://m.facebook.com/profile".freeze

  class ActivityLog
    attr_reader :email, :pass

    def initialize(email, pass)
      @email = email
      @pass = pass
      @agent = Mechanize.new { |agent| agent.user_agent_alias = 'iPhone' }
    end

    def login
      home_page = @agent.get(HOMEPAGE_URL)
      login_form = home_page.form
      login_form.field_with(:name => 'email').value = @email
      login_form.field_with(:name => 'pass').value = @pass

      login_page = @agent.submit login_form
      if login_page.body.match('Your password was incorrect.')
        raise InvalidLoginCredentials, "Your password was incorrect."
      end
    end

    def user_id
      unless @user_id
        profile_page = @agent.get(PROFILE_URL)
        @user_id = profile_page
                    .links_with(:text => 'Activity Log')
                    .first
                    .href
                    .match(%r{/(\d+)/})
                    .captures
                    .first
      end

      return @user_id
    end

    def reg_year
      unless @reg_year
        activity_page = @agent.get("#{HOMEPAGE_URL}/#{self.user_id}/allactivity")
        year_divs = activity_page
                    .parser
                    .xpath("//div[@id[starts-with(.,'year_')]]")

        years = year_divs.collect do |div|
          div.attribute('id').to_s.gsub(/^year_/, '')
        end

        @reg_year = if years.empty?
                      Date.today.year
                    else
                      years.min
                    end
      end

      return @reg_year
    end
  end

  class InvalidLoginCredentials < Exception; end;
end
