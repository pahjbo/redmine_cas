require 'redmine'
require 'redmine_cas'
require 'redmine_cas/application_controller_patch'
require 'redmine_cas/account_controller_patch'

require_dependency 'redmine_cas_hook_listener'

Redmine::Plugin.register :redmine_cas do
  name 'Redmine CAS'
  author 'Nils Caspar (Nine Internet Solutions AG)'
  description 'Plugin to CASify your Redmine installation.'
  version '1.2.1'
  url 'https://github.com/pahjbo/redmine_cas'
  author_url 'http://www.nine.ch/'

  settings :default => {
    'enabled' => false,
    'redirect' => true,
    'cas_url' => 'https://',
    'attributes_mapping' => 'firstname=first_name&lastname=last_name&mail=email',
    'autocreate_users' => false
  }, :partial => 'redmine_cas/settings'

  Rails.configuration.to_prepare do
    ApplicationController.send(:include, RedmineCAS::ApplicationControllerPatch)
    AccountController.send(:include, RedmineCAS::AccountControllerPatch)
  end
  ActionDispatch::Callbacks.before do
    RedmineCAS.setup!
  end
end
