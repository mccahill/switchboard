class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    return do_page if params[:view_type] == 'table'
    
    @activities = Activity.includes([:ip, :user, :link_request => [approvals: :ip]]).where("link_request_id IS NOT NULL" ).reverse_order
    @actHash = {}
    @activities.each do |a|
      dString = a.occurred.strftime("%b %d")
      @actHash[dString] = [] unless @actHash.has_key? dString
      
      if a.ip.blank?
        desc = a.link_request.display
      else
        desc = a.ip.short_fqdn 
        if !a.ip.vlan.blank?
          desc += " with VLAN: #{a.ip.vlan.display}"
        end
              
      end
      
      @actHash[dString] << {url: "<a href='/link_requests/#{a.link_request.id}'>#{desc} - #{a.verb} by #{a.user.displayName}</a>",
         acttime: a.occurred.strftime("%I:%M %p")}

    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @actHash }
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url }
      format.json { head :no_content }
    end
  end

  def sort
    return do_page
  end
  
  private
  
    def do_page
      @items = {"Actor"=>'', 'Action'=>'verb',  "Ip" => "",  'Link Request'=>'', 'When' => 'occurred'}
      @curOrder =params[:curOrder].presence || "occurred"
      @curDir = params[:curDir].presence || 'false'
      @order = params[:order].presence || @curOrder
      @searchClause = params[:searchClause]
      
      if @curOrder.eql?(@order)
        @curDir = @curDir.eql?('false') ? true : false
      else
        @curDir = false
        @curOrder = @order
      end
      ob = "#{@curOrder} "+ (@curDir ? 'DESC':'ASC')
      
      unless @searchClause.blank?
        sc = <<-SQL 
SELECT * FROM (
SELECT a.* from activities a
INNER JOIN link_requests lr ON lr.id = a.link_request_id
INNER JOIN approvals ap ON lr.id = ap.link_request_id
JOIN ips ON ap.ip_id = ips.id
JOIN vlans ON vlans.id = ips.vlan_id
WHERE UPPER(ips.fqdn) like ?
UNION
SELECT a.* FROM activities a
INNER JOIN users u ON a.user_id = u.id
WHERE UPPER(u.netid) LIKE ?
OR UPPER(u.displayName) LIKE ?
OR UPPER(a.verb) LIKE ?
) allacts ORDER BY ?
SQL
        clike = "%#{@searchClause.upcase}%"
        @acts = Activity.paginate_by_sql([sc, clike,clike,clike,clike,ob],:page => params[:page])
      
      else
        @acts = Activity.includes([:ip, :user, :link_request => [approvals: :ip]]).order(ob).paginate(:page => params[:page])
        
      end
      respond_to do |format|
        format.html { render :index_table}
        format.csv { send_data Activity.to_csv(@acts) }
        format.json { render json: @acts }
      end
      
    end
  
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params[:activity]
    end
end
