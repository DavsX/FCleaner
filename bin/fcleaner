#!/usr/bin/env ruby

require 'io/console'
require_relative '../lib/fcleaner'

print "Enter email: "
email = gets.chomp

print "Enter password: "
pass = STDIN.noecho(&:gets).chomp

puts ''

alog = FCleaner::ActivityLog.new email, pass
alog.login
alog.clean
