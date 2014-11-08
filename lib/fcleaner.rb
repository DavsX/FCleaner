require 'mechanize'
require 'date'

module FCleaner
  HOMEPAGE_URL = "https://m.facebook.com".freeze
  LOGIN_URL    = "#{HOMEPAGE_URL}/login.php".freeze
  PROFILE_URL  = "#{HOMEPAGE_URL}/profile".freeze

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

    def activity_page_url(timestamp)
      "#{HOMEPAGE_URL}/#{user_id}/allactivity?timeend=#{timestamp}"
    end

    def clean
      start_date = Date.new(@reg_year, 1, 1)
      today = Date.today
      end_date = Date.new(today.year, today.month, 1)

      (start_date..end_date).select {|d| d.day == 1}.each do |date|
        puts "Cleaning #{date}"
        clean_month(date.year, date.month)
      end
    end

    def clean_month(year, month)
      timestamp = DateTime.new(year, month, -1, 23, 59, 59).to_time.to_i
      activity_url = activity_page_url(timestamp)

      activity_page = @agent.get(activity_url)

      activities = activity_page
                    .parser
                    .xpath("//div[@id[starts-with(.,'u_0_')]]")

      activities.each do |activity|
        action = ['Delete','Delete Photo','Unlike','Hide from Timeline'].detect do
          |text| !activity.xpath(".//a[text()='#{text}']").empty?
        end

        if action
          url = activity
                  .xpath(".//a[text()='#{action}']")
                  .first
                  .attribute('href')
                  .value

          @agent.get(url)
        end
      end
    end

    def user_id
      @user_id ||= build_user_id
    end

    def reg_year
      @reg_year ||= build_reg_year
    end

    def build_user_id
      @agent.get(PROFILE_URL)
        .links_with(:text => 'Activity Log')
        .first
        .href
        .match(%r{/(\d+)/})
        .captures
        .first
    end

    def build_reg_year
      year_divs = @agent.get("#{HOMEPAGE_URL}/#{self.user_id}/allactivity")
                  .parser
                  .xpath("//div[@id[starts-with(.,'year_')]]")

      years = year_divs.collect do |div|
        div.attribute('id').to_s.gsub(/^year_/, '')
      end

      if years.empty?
        Date.today.year
      else
        years.min
      end
    end
  end

  class InvalidLoginCredentials < Exception; end;
end
