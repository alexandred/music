class GenericMailer < ActionMailer::Base
  default from: ::Configuration['email_contact']
  layout 'email'

  def recommend_to_friend(friend,friendemail,user,project)
  	@name = friend
  	@user = user
  	@project = project
  	mail(to: friendemail, subject: t('notifications.recommend_to_friend.subject', name: @user.full_name))
  end
end
