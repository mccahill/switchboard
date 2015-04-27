class ControllerCommandStack < ActiveRecord::Base
  
  # we use a super-simple table (controller_command_stacks) to store 
  # the commands that have been issued to the SDN controller so that
  # we can replay them to restore the state of the SDN switches
  # in the event the controller is restarted, or we want to
  # roll back to some previous state. 
  # 
  
end
