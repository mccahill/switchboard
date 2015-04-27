class SwitchInitialConfig < ActiveRecord::Base
   has_one :switch
   has_one :switch_connection_type

   def network_type
     SwitchConnectionType.find(self.switch_connection_type_id).name
   end

   def switch_name
     Switch.find(self.switch_id).name
   end
  
   def switch_description
     Switch.find(self.switch_id).description
   end
  
end
