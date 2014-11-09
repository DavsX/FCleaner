# FCleaner

FCleaner allows you to clean up your Activity Log on Facebook. I like to erase
my activity on Facebook from time to time, so I created this gem.

This gem is in early stage, use with caution on you own risk!

At this stage, all the Activity Log entries that can be deleted, unliked and 
hidden gets deleted, unliked and hidden, including your (profile) pictures!
Search data are not yet deleted.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'FCleaner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install FCleaner

## Usage

To completely erase you Activity Log, use:

```ruby
    $ fcleaner.rb
    Enter email: email@example.com
    Enter password: ****
```

For more fine-grained control you can write your own script:

```ruby
    #!/usr/bin/env ruby

    require 'io/console'
    require 'fcleaner'

    print "Enter email: "
    email = gets.chomp

    print "Enter password: "
    pass = STDIN.noecho(&:gets).chomp

    puts ''

    activity_log = FCleaner::Activitylog.new email, pass
    activity_log.login

    activity_log.clean #attempts to erase everything

    #or

    registration_year = activity_log.reg_year
    activity_log.clean_month(registration_year, 1)
    activity_log.clean_month(registration_year, 2)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/FCleaner/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
