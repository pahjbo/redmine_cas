RedmineApp::Application.routes.draw do
  get 'cas', :to => 'account#cas'
  post 'cas', :to => 'account#cas'
  get 'cas/register', :to => 'account#cas_user_register'
  post 'cas/register', :to => 'account#cas_user_register'
end
