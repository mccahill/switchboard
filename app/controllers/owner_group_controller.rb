class OwnerGroupController < ApplicationController
  before_filter :onlyAdmin
  before_action :set_owner_group, only: [:show, :edit, :update, :destroy]
  
  def index
    return do_page
  end
  
  
  def sort
    return do_page
  end

  def show
    
  end

   def new
    @group = OwnerGroup.new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
  
  def ajax_users
    list = {}
    foo = []
    if params[:term]
      list = LdapTool.userLookup(params[:term])
      list.each_pair do |netid, name|
        row = {}
        row['label'] = name
        row['value'] = netid
        foo << name
      end
    end
    render json: foo
  end
  
  def add_user
    netid = params[:netid]
    group = OwnerGroup.find(params[:groupid])
    
    unless netid.blank? or group.blank?
      user = User.find_or_create_from_netid(netid)
      group.users << user
      group.save
    end
    render json: user
  end
  
  def rm_user
    user = User.where(netid: params[:netid]).first
    group = OwnerGroup.find(params[:groupid])
    unless user.blank? or group.blank?
      group.users.delete user
      group.save
    end
    render json: nil
  end
  
  def items
    {'Name' => "name", "Date created" => "created_at" , "Members" => "not_sortable",
      "Manages" => "not_sortable"}
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_owner_group
      @group = OwnerGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def owner_group_params
      params.require(:owner_group).permit(:id, :name)
    end
  
    def do_page
      @curOrder =params[:curOrder].presence || "name"
      @curDir = params[:curDir].presence || 'true'
      @order = params[:order].presence || @curOrder
      @searchClause = params[:searchClause]

      @curDir = @curDir.eql?('true') 

      if @curOrder.eql?(@order)
        @curDir = !@curDir
      else
        @curDir = false
        @curOrder = @order   
      end
      ob = "#{@curOrder} "+ (@curDir ? 'DESC':'ASC')
      
      unless @searchClause.blank?
        c = @searchClause.upcase
        sc = "UPPER(name) like ? " +
             "OR UPPER(users.displayName) like ? " +
             "OR UPPER(mac_addrs.address) like ? "
        clike = '%'+c+'%'
        
        @groups = OwnerGroup.joins(:users).where("UPPER(name) like ? OR UPPER(users.displayName) like ?", clike,clike).uniq.order(ob).paginate(:page => params[:page])
      else
        @groups = OwnerGroup.all.order(ob).paginate(:page => params[:page])        
      end
      @items = items()
      render :action=>:index      
    end
end
