#!/usr/bin/env ruby
################################################################################
# hs.rb - Hokie Stalker                                                        #
# Query the Virginia Tech LDAP server for information about a person.          #
#                                                                              #
# Original author: mutantmonkey <mutantmonkey@gmail.com>                       #
# Original location: github.com/mutantmonkey/hokiestalker                      #
# Ruby port by: Ben Weinstein-Raun <benwr@vt.edu>                              #
################################################################################

#Usage: `ruby hs.rb <name|pid|email>`

begin
  require 'net-ldap'
rescue LoadError
  require 'rubygems'
  require 'net-ldap'
end

LDAP_URI = "directory.vt.edu"

def pretty_print(label, data)
  label = label + ":"
  data.each do |field|
    printf "%-20s%s\n", label, field
    label = ''
  end
end

def search(filter)
  ldap = Net::LDAP.new :host => LDAP_URI
  treebase = "dc=vt, dc=edu"
  result = ldap.search(:base => treebase, :filter => filter)

  return false if result.length <= 0

  printables = { # attributes for printing, and their associated labels
    :cn =>                  'Name',
    :uid =>                 'UID',
    :uupid =>               'PID',
    :mail =>                'Email',
    :major =>               'Major',
    :department =>          'Department',
    :title =>               'Title',
    :postaladdress =>       'VT Address',
    :mailstop =>            'Mail Stop',
    :telephonenumber =>     'VT Phone',
    :localpostaladdress =>  'Home Address',
    :localphone =>          'Personal Phone'
  }

  result.each do |person|
    person.each do |attribute, value| # value: array containing attr values.
      if printables.include? attribute              # We want to print this attr

        if printables[attribute].include? "Address" # Extra step for addresses
          pretty_print printables[attribute], value[0].split('$')

        elsif not (attribute == :department and person[:major].length > 0)
          # we don't want to show department if major is available too
          pretty_print printables[attribute], value
        end
      end
    end
    puts "\n" # newline separates records
    return true
  end
end

querybits = ARGV[0..-1]
query = querybits.join(" ")

# Initially try search by PID
filter = Net::LDAP::Filter.eq("uupid",query)
success = search(filter)

# Try partial search on full name (CN) if no pid hits
if not success
  filter = Net::LDAP::Filter.eq("cn","*" + querybits.join("*") + "*")
  success = search(filter)
end

# Finally, check to see if it was an email address
if not success
  filter = Net::LDAP::Filter.eq("mail", query)
  success = search(filter)
end

if not success
  puts "No Results Found."
end

