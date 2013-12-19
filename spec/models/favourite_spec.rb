require 'spec_helper'

describe Favourite do
  let(:project){ build(:project, state: 'online') }
  let(:user){ create(:user) }

  describe 'associations' do
  	it { should belong_to :project }
  	it { should belong_to :user }
  	it { should have_many :notifications }
  end

  describe 'notification' do
  	let(:project){ create(:project, online_days: 10) }
  	let(:user) { create(:user) }
  	let(:favourite) { create(:favourite, project_id: project.id)}

  	subject { favourite.state }

  	context 'before 48h' do
  		before { favourite.finish }
  		it { should == 'pending'}
  	end

  	describe 'after 48h' do
  		before { 
  			project.update_attributes online_days: 1
  			favourite.finish
  		 }
  		it { should == 'notified' }
  	end
  end
end
