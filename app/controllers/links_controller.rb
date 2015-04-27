class LinksController < ApplicationController
  before_action :set_link, only: [:show]

  # GET /links
  # GET /links.json
  def index
    @links = LinkRequest.valid
  end

  # GET /links/1
  # GET /links/1.json
  def show
    redirect_to @link if request.format == Mime::HTML
  end

  private
  
    def restUsers
      #APP_CREDS['sn_ws_users']
      {'vincent' => 'testing123'}
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = LinkRequest.find(params[:id])
    end
    
		# Override authorize in application_controller.rb
    def authorize
      case request.format
      when Mime::JSON
        ru = restUsers()
        logger.debug "inside authenticate"
        authenticate_or_request_with_http_basic do |user_name, password|
          ru.keys.include?(user_name) && password == ru[user_name]
        end
      else
        super
      end
    end
end
