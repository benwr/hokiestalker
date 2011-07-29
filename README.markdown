# Hokie Stalker #
Stalk your friends! Creep people out! Find email addresses and phone numbers!
Learn to play Beethoven in Five Hours!

## Credits ##
Shamelessy stolen and poorly ported from [mutantmonkey](http://mutantmonkey.in), who wrote
it in python. Only reason for the port: Python has version issues right now,
including but not limited to a current lack of LDAP modules in version 3
(the version most convenient for me atm).

Released under the new BSD license.

## Prerequisites ##
* Ruby
* net-ldap package, installable with `gem install net-ldap`

## Installation ##
1. `git clone git://github.com/benwr/hokiestalker.git`
2. `chmod +x hokiestalker/hs.rb`
3. `mv hokiestalker/hs.rb <a directory in your $PATH>/hs`
4. `rm -rf hokiestalker`

## Usage ##
* VT PID Search: `hs benwr`
* VT Email Search: `hs benwr@vt.edu`
* Name Search (Careful; some searches with frequent hits will take a long time): `hs Ben Weinstein`

To override the PID search (for example, if you're looking for someone whose
name is jones, but someone else has the PID 'jones'), use the `-n` flag: `hs -n
jones`.



