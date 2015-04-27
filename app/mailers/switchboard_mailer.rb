class SwitchboardMailer < ActionMailer::Base
  default from: "switchboard@duke.edu"
  
  def approval_request_email(email_list, link_request)
    
    @desc = link_request.status_description
    # @url = url_for(host: 'localhost:3000', controller: :link_request, action: :view link_request
    @url = link_request_url(link_request, host:'localhost:3000')
    @user = link_request.user
    mail(to:email_list, subject: 'SDN connection request')
  end
end
