class LinkRequestsController < ApplicationController
  before_action :set_link_request, only: [:show, :edit, :update, :destroy, :approve, :deny]

  def index_get
    return do_page(cookies[:justMine], cookies[:show_admin],cookies[:show_admin_approval])
  end

  def index
    return do_page
  end

  def sort
    return do_page
  end

  # GET /link_requests/1
  # GET /link_requests/1.json
  def show
    
  end

  # GET /link_requests/new
  def new
    @link_request = LinkRequest.new
    2.times { 
      ap = @link_request.approvals.build 
      ap.ip = Ip.new
      ap.ip.vlan = Vlan.first  #default to the first VLAN, which is the default (null) VLAN
    }
  end

  # GET /link_requests/1/edit
  def edit
    respond_to do |format|
      format.html { redirect_to @link_request, notice: 'Updates to requests are not allowed' }
      format.json { render json: ["updates not allowed"], status: :unprocessable_entity }
    end
    
  end

  # POST /link_requests
  # POST /link_requests.json
  def create
    logger.info "link_requests_controller.create: you have #{link_request_params}"
    
    @link_request = LinkRequest.new(link_request_params)
    @link_request.user = @user
    respond_to do |format|
      if @link_request.save
        @link_request.initial_approvals(@user)  # Approve what you can as the originator
        @link_request.send_approval_request
        format.html { redirect_to @link_request, notice: 'Link request was successfully created.' }
        format.json { render :show, status: :created, location: @link_request }
      else
        format.html { render :new }
        format.json { render json: @link_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /link_requests/1
  # PATCH/PUT /link_requests/1.json
  def update
    respond_to do |format|
      format.html { redirect_to @link_request, notice: 'Updates to requests are not allowed' }
      format.json { render json: ["updates not allowed"], status: :unprocessable_entity }
    end
  end

  # DELETE /link_requests/1
  # DELETE /link_requests/1.json
  def destroy
    unless @link_request.owned_by(@user)
      logger.error "#{@user.netid} tried to delete request #{@link_request.id}"
      return redirect_to link_requests_path, notice: "You do not have enough access to delete that request"
    end
    # if @link_request.status == :approved
      @link_request.delete_by(@user)
    # else
    #   @link_request.destroy
      Activity.create(user: @user, verb: 'destroy', link_request: @link_request, occurred: Time.now)
    # end
  
    respond_to do |format|
      format.html { redirect_to link_requests_url }
      format.json { head :no_content }
    end
  end
  
  def approve
    respond_to do |format|
      if @link_request.approve_by(@user)
        format.html { redirect_to @link_request, notice: 'Link request was succesfully approved' }
        format.json { render :show, status: :ok, location: @link_request }
      else
        format.html { redirect_to @link_request, notice: 'Failed to approve request' }
        format.json { render json: @link_request.errors, status: :unprocessable_entity }
      end
    end
  end
 
  def deny
    respond_to do |format|
      if @link_request.deny_by(@user)
        format.html { redirect_to @link_request, notice: 'Link request was succesfully denied' }
        format.json { render :show, status: :ok, location: @link_request }
      else
        format.html { redirect_to @link_request, notice: 'Failed to deny request' }
        format.json { render json: @link_request.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def items
    {'Host A' => 'not_sortable', 'Host B' => 'not_sortable',  
      'Requester' => 'user_id', 'Date Requested' => 'created_at', 'Status' => "status"}
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_link_request
      @link_request = LinkRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_request_params
      params.require(:link_request).permit(:id, :show_admin, :traffic, :comment, :duration, 
                                            approvals_attributes: [ :status, ip_attributes:[:fqdn, :vlan_id] ])
    end
    
    def do_page(init_justmine = true, init_showadmin = false, init_show_admin_approval=false)
      @curOrder =params[:curOrder].presence || "created_at"
      @curDir = params[:curDir].presence || 'false'
      @order = params[:order].presence || @curOrder

      f= params[:just_mine].presence || init_justmine
      
      @justMine = f.eql? 'true'
      if @user.isAdmin?
        f = params[:show_admin].presence || init_showadmin
        @show_admin = f.eql? 'true'
      else
        @show_admin = false
      end

      if @curOrder.eql?(@order)
        @curDir = @curDir.eql?('false') ? true : false
      else
        @curDir = false
        @curOrder = @order
      end
      ob = "#{@curOrder} "+ (@curDir ? 'DESC':'ASC')

      f= params[:show_admin_approval].presence || init_show_admin_approval
      @adminApproval = f.eql? 'true'
      if @adminApproval
        @approvals = LinkRequest.getApprovalsForUser()
      else
        @approvals = LinkRequest.getApprovalsForUser(@user)
      end
      

      if @justMine
        @reqs = @show_admin ?  LinkRequest.all.order(ob) :  @user.link_requests.order(ob)
        
      else
        @reqs = LinkRequest.joins(approvals: [owner_group: :users]).where(
        "(link_requests.user_id = #{@user.id}) OR (" +
        "owner_groups_users.user_id = #{@user.id} " +
        ")").order(ob).uniq
      end
      @items = items()
      logger.info "items is #{@items}"
      cookies[:justMine] = @justMine
      cookies[:show_admin]=@show_admin
      cookies[:show_admin_approval]=@adminApproval
      @reqs = @reqs.paginate(:page => params[:page])
      render :action=>:index
      
    end
    
end
