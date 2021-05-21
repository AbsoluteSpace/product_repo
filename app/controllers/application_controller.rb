class ApplicationController < ActionController::Base

    protected 

    def verify_is_admin
        (current_user.nil?) ? redirect_back(fallback_location: "/") : (redirect_back(fallback_location: "/") unless current_user.admin?)
    end

end
