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
rescue
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

def parse_addr(addr)
  return addr[0].split('$')
end

def search(filter)
  ldap = Net::LDAP.new :host => LDAP_URI
  treebase = "dc=vt, dc=edu"
  if (result = ldap.search(:base => treebase, :filter => filter)).length > 0
    result.each do |person|
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

      person.each do |attribute, value|# value: an array containing attribute for person.
        if printables.include? attribute
          if printables[attribute].include? "Address" # Extra step for addresses
            pretty_print printables[attribute], parse_addr(value)
          elsif not (attribute == :department and person[:major].length > 0)
            # we don't want to show information that is certainly redundant.
            pretty_print printables[attribute], value
          end
        end
      end
      puts "\n"
    end
    return true # We found at least one person that fits the criteria
  else
    return false # We didn't find anyone
  end
end

success = false

# Initially try search by PID, unless -n flag specified
if not ARGV.delete("-n")
  filter = Net::LDAP::Filter.eq("uupid",query)
  success = search(filter)
end

# Try partial search on full name (CN) if no pid hits
if not success
  filter = Net::LDAP::Filter.eq("cn","*" + ARGV.join("*") + "*")
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

