class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :authorize

  private
  def authorize
    if (ENV['RAILS_ENV'].include? 'dev') && (! request.env.include? 'REMOTE_USER')
      netid = 'mccahill'
    else
      netid = request.env['REMOTE_USER'].split("@").first
    end

    @user = User.find_by_netid(netid)

    @user = User.new(netid: netid) if @user.blank?
    if request.env.include? 'REMOTE_USER'
      @user.duid = request.env['Shib-Duke-Unique-Id']
      @user.displayName = request.env['displayName']
      @user.email = request.env['mail']
      @user.phone = request.env['telephoneNumber']
    end
    @user.save
    session[:user_id] = @user.id  
  end
  
	def onlyAdmin
    session[:user_id] = @user.id  
    unless @user.isAdmin?
      logger.warn "User #{@user.netid} tried to access an Admin-Only Controller: #{params[:controller]}"
      redirect_to "/"
    end
	end

  
end
