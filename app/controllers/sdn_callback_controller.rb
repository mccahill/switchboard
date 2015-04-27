class SdnCallbackController < ApplicationController
  # 
  # After the SDN controller is restarted it forgets all the configuration info switchboard
  # has sent it, and so needs to have it's state restored. To do this, there is a REST web services
  # call:
  #
  #      https://switchboard.oit.duke.edu/sdn_callback/restore_state?rest_caller_id=PUT_REAL_USER_HERE&rest_caller_pw=PUT_REAL_PASSWORD_HERE
  #
  # Ideally the startup script for the SDN controller would wait until the switches have all synced
  # with the controller and then request switchboard that switchboard restore it's state.
  #

  
  def return_results
    respond_to do |format|
      format.html { render :layout => false, :json => @restore_state_result }
      format.json { render :layout => false, :json => @restore_state_result }
    end 
  end
  
  def restore_state
    r = RyuController.new
    synthetic_user = {:netid => 'SdnCallbk'}
    @restore_state_result = r.playback_commands_from_stack(synthetic_user) 
    return_results
  end
  
  private  
  # Override authorize in application_controller.rb
  def authorize
    if  !((params[:rest_caller_id] == APP_CONFIG['RESTORE_SDN_STATE_ID']) and 
          (params[:rest_caller_pw] == APP_CONFIG['RESTORE_SDN_STATE_PW'] ))
        logger.info("Unauthorized SdnCallback access with rest_caller_id=#{params[:rest_caller_id]} and rest_caller_pw=#{params[:rest_caller_pw]}")
        @restore_state_result = {:error => "invalid SdnCallback authorization credentials"}
        return_results
    end
  end

end
