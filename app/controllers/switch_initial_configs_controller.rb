class SwitchInitialConfigsController < ApplicationController
  
  before_filter :onlyAdmin
  before_action :set_switch_initial_config, only: [:show, :edit, :update, :destroy]
  before_action :cleanup_spaces, only: [:show, :edit, :update]
  
  # GET /switch_initial_configs
  # GET /switch_initial_configs.json
  def index
    @switch_initial_configs = SwitchInitialConfig.all
  end

  # GET /switch_initial_configs/1
  # GET /switch_initial_configs/1.json
  def show
  end

  # GET /switch_initial_configs/new
  def new
    @switch_initial_config = SwitchInitialConfig.new
  end

  # GET /switch_initial_configs/1/edit
  def edit
    
  end

  # POST /switch_initial_configs
  # POST /switch_initial_configs.json
  def create
    if user_entered_valid_ip( switch_initial_configs_url )
      @switch_initial_config = SwitchInitialConfig.new(switch_initial_config_params)
      respond_to do |format|
        if @switch_initial_config.save
          format.html { redirect_to @switch_initial_config, notice: 'Switch initial config was successfully created.' }
          format.json { render :show, status: :created, location: @switch_initial_config }
        else
          format.html { render :new }
          format.json { render json: @switch_initial_config.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /switch_initial_configs/1
  # PATCH/PUT /switch_initial_configs/1.json
  def update
    if user_entered_valid_ip( @switch_initial_config )
      @switch_initial_config.update(switch_initial_config_params)
      respond_to do |format|
        if @switch_initial_config.update(switch_initial_config_params)
          format.html { redirect_to @switch_initial_config, notice: 'Switch initial config was successfully updated.' }
          format.json { render :show, status: :ok, location: @switch_initial_config }
        else
          format.html { render :edit }
          format.json { render json: @switch_initial_config.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /switch_initial_configs/1
  # DELETE /switch_initial_configs/1.json
  def destroy
    @switch_initial_config.destroy
    respond_to do |format|
      format.html { redirect_to switch_initial_configs_url }
      format.json { head :no_content }
    end
  end

  private
    def user_entered_valid_ip( return_to_location )
      begin
        testing = IPAddress switch_initial_config_params[:ip]
      rescue => error_message
        respond_to do |format|
          format.html { redirect_to return_to_location, notice: "Cannot complete operation: #{error_message}"}
          format.json { render json: @switch_initial_config.errors, status: :unprocessable_entity }
        end
        return false
      else
        return true
      end     
    end
    
    
    def cleanup_spaces
      if !@switch_initial_config.vlan.nil?
        # strip any spaces from the vlan name
        @switch_initial_config.vlan = @switch_initial_config.vlan.gsub(' ', '')
        if @switch_initial_config.vlan.blank?
          @switch_initial_config.vlan = nil
        end
      end      
      if !@switch_initial_config.ip.nil?
        # strip any spaces from the ip address
        @switch_initial_config.ip = @switch_initial_config.ip.gsub(' ', '')
        if @switch_initial_config.ip.blank?
          @switch_initial_config.ip = '1.1.1.1/32' #bogus address as a placeholder
        end
      end      
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_switch_initial_config
      @switch_initial_config = SwitchInitialConfig.find(params[:id])
      cleanup_spaces
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def switch_initial_config_params
      params.require(:switch_initial_config).permit(:ip, :vlan, :switch_connection_type_id, :switch_id)
    end
end
