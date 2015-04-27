class Switch < ActiveRecord::Base
  has_many :switch_initial_configs
  
  def switch_configs
    SwitchInitialConfig.find_by_sql("SELECT * FROM 
        switch_initial_configs WHERE 
        switch_initial_configs.switch_id = '#{self.id}'")
  end

  
end
