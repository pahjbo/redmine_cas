# Redmine CAS plugin

This is a fork of Ninech's <a href="https://github.com/ninech/redmine_cas">Redmine CAS Plugin</a>.
The key differences:

* Adjusted to work on Redmine 3.4.
* Show a registration form when creating new users on the fly.
* Configure whether users are automatically redirected to the CAS login page when signin in.

## Compatibility

Tested with Redmine 3.4

## Installation

1. Download or clone this repository and place it in the Redmine `plugins` directory as `redmine_cas`
2. Restart your webserver
3. Open Redmine and check if the plugin is visible under Administration > Plugins
4. Follow the "Configure" link and set the parameters
5. Party

## Notes

### Usage

If your installation has no public areas ("Authentication required") and you are not logged in, you will be redirected to the login page. The login page will show a link that lets the user login with CAS.

When "Automatic redirect" is enabled, users are automatically redirected to the CAS server, without showing the login page. To access the login page, you will need to access it directly (http://example.com/path-to-redmine/login).

### Single Sign Out, Single Logout

The sessions have to be stored in the database to make Single Sign Out work.
You can achieve this with a tiny plugin: [redmine_activerecord_session_store](https://github.com/pencil/redmine_activerecord_session_store)

### Auto-create users

By enabling this setting, successfully authenticated users can register themselves to Redmine during their first login. Note: These user accounts are always created as active users, regardless of the self registration settings in Redmine.

## Copyright

Copyright (c) 2013-2014 Nine Internet Solutions AG. See LICENSE.txt for further details.
Copyright (c) 2017 Joeri Jongbloets.
