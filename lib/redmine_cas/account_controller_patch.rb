require 'redmine_cas'

module RedmineCAS
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :logout, :cas
      end
    end

    module InstanceMethods
      def logout_with_cas
        # if CAS module is inactive or no CAS Session is active
        # logout in regular fashion
        if !RedmineCAS.enabled? || session[:cas_user].empty?
          return logout_without_cas
        else
          logout_user
          CASClient::Frameworks::Rails::Filter.logout(self, home_url)
      end

      def cas
        return redirect_to :action => 'login' unless RedmineCAS.enabled?

        if User.current.logged?
          # User already logged in.
          return redirect_to_ref_or_default
        end

        if CASClient::Frameworks::Rails::Filter.filter(self)
          user = User.find_by_login(session[:cas_user])

          # Auto-create user if possible
          if user.nil? && RedmineCAS.autocreate_users?
            return redirect_to :action => 'cas_user_register'
          end

          return cas_user_not_found if user.nil?
          return cas_account_pending unless user.active?

          user.update_attribute(:last_login_on, Time.now)
          user.update_attributes(RedmineCAS.user_extra_attributes_from_session(session))
          if RedmineCAS.single_sign_out_enabled?
            # logged_user= would start a new session and break single sign-out
            User.current = user
            start_user_session(user)
          else
            self.logged_user = user
          end

          redirect_to_ref_or_default
        end
      end

      def redirect_to_ref_or_default
        default_url = url_for(params.merge(:ticket => nil))
        if params.has_key?(:ref)
          # do some basic validation on ref, to prevent a malicious link to redirect
          # to another site.
          new_url = params[:ref]
          if /http(s)?:\/\/|@/ =~ new_url
            # evil referrer!
            redirect_to default_url
          else
            redirect_to request.base_url + params[:ref]
          end
        else
          redirect_to default_url
        end
      end

      def cas_user_register
        # check that we have an active CAS Session
        if CASClient::Frameworks::Rails::Filter.filter(self)
          # search for existing users with same name
          user = User.find_by_login(session[:cas_user])
          # if username is in database throw error
          if !user.nil?
            return cas_user_already_exists user
          end

          # check whether we have form data
          if !request.post?
            # create user object
            @user = User.new(:language => Setting.default_language, :admin => false)
            @user.login = session[:cas_user]
            # pre-fill with information from CAS Ticket
            @user.assign_attributes(RedmineCAS.user_extra_attributes_from_session(session))
          else
            # process post params
            user_params = params[:user] || {}

            @user = User.new
            @user.safe_attributes = user_params
            # we always set the login to the username of the cas session
            @user.login = session[:cas_user]
            # we do not allow for admin creation
            @user.admin = false
            # generate random password
            @user.register

            # try to save
            if @user.save
              self.logged_user = @user

              if user.active?
                flash[:notice] = l(:notice_account_activated)
                return redirect_to my_account_path
              else
                return cas_account_pending
              end # end of active
            end # end of save

            # always return form at this stage
            return render "redmine_cas/cas_user_register"
          end # end of check post
          return cas_failure
        end # end of filter 
      end

      def cas_account_pending
        render_403 :message => l(:notice_account_pending)
      end

      def cas_user_not_created(user)
        logger.error "Could not auto-create user: #{user.errors.full_messages.to_sentence}"
        render_403 :message => l(:redmine_cas_user_not_created, :user => session[:cas_user])
      end

      def cas_failure
        render_403 :message => l(:redmine_cas_failure)
      end

    end
  end
end
