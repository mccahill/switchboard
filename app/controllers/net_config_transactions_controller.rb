class NetConfigTransactionsController < ApplicationController
  # active_scaffold :"net_config_transaction" do |config|
  #     config.actions = [:list, :search]
  #     config.list.sorting = { :id => :desc }
  #     config.columns = [ :id, :who, :target, :command, :status, :response, :created_at ]
  #     config.label = 'RYU Controller transactions'
  # end
  
  def index
    return do_page
  end
  
  
  def sort
    return do_page
  end
  
  def items
    {"User" => "who", "Target" => "target", "Description" => "description", 
     "Status"=>"status", "Command" => "command", "Response"=>"response",
     "When" => "created_at", "ID" =>"id"}
  end
  
  private
  def do_page
    @curOrder =params[:curOrder].presence || "id"
    @curDir = params[:curDir].presence || 'false'
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
      sc = "UPPER(who) like ? " +
           "OR UPPER(command) like ? " +
           "OR UPPER(response) like ? "
      clike = '%'+c+'%'    
      @transactions = NetConfigTransaction.where(sc,clike, clike,clike).uniq.order(ob).paginate(:page => params[:page])
    else
      @transactions = NetConfigTransaction.all.order(ob).paginate(:page => params[:page])     
    end
    @items = items()
    render :action=>:index      
  end
  
end
