require 'rails_helper'

RSpec.describe 'BatchJob' do
  let(:resource_class) { BatchJob }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('BatchJob')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:update, :index, :show, :edit, :destroy)
  end

  it 'should not have new or create actions' do
    expect(resource.defined_actions).to_not include(:new, :create)
  end

  it 'should have batch_actions' do
    expect(resource.batch_actions.map(&:sym)).to include(:destroy)
  end
end