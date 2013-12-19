class Favourite < ActiveRecord::Base
  schema_associations
  attr_accessible :project_id
  attr_accessible :user_id
  attr_accessible :about_attributes
  validates :project_id, uniqueness: true, presence: true

  state_machine :state, initial: :pending do
  	state :pending, value: 'pending'
  	state :notified, value: 'notified'


  	event :finish do
  		transition pending: :notified , if: ->(favourite) {
  			Time.now.getutc > favourite.project.expires_at - 48.hours
  		}
  	end

  	after_transition pending: :notified, do: :after_transition_of_pending_to_notified
  end

  def after_transition_of_pending_to_notified
  	notify_observers :notify_user_that_project_is_expiring
  end

  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def self.finish_all!
    Favourite.where(state: 'pending').each do |resource|
      resource.finish
    end
  end
end
