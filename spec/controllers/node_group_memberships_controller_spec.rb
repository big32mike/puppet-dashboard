require 'spec_helper'
require 'shared_behaviors/controller_mixins'

describe NodeGroupMembershipsController, :type => :controller do
  describe "#create" do
    render_views

    it "should accept a node id and group id and make a membership" do
      node = create(:node)
      group = create(:node_group)

      post :create, params: { node_group_membership: { node_id: node.id, node_group_id: group.id }, format: 'json' }

      NodeGroupMembership.count.should == 1

      response.should be_successful
      membership = NodeGroupMembership.first
      membership.node_id.should == node.id
      membership.node_group_id.should == group.id
    end

    it "should not create duplicate memberships" do
      node = create(:node)
      group = create(:node_group)
      membership = NodeGroupMembership.create!(:node => node, :node_group => group)

      post :create, params: { node_group_membership: { node_id: node.id, node_group_id: group.id }, format: 'json' }

      response.should_not be_successful
      NodeGroupMembership.count.should == 1
      NodeGroupMembership.first.should == membership
    end

    it "should be able to create a membership using node and group names" do
      node = create(:node)
      group = create(:node_group)

      post :create, params: { node_name: node.name, group_name: group.name, format: 'json' }

      response.should be_successful
      NodeGroupMembership.count.should == 1
      membership = NodeGroupMembership.first
      membership.node_id.should == node.id
      membership.node_group_id.should == group.id
    end

    it "should fail if given a non-existent node name" do
      group = create(:node_group)

      post :create, params: { node_name: 'missing', group_name: group.name, format: 'json' }

      response.should_not be_successful
      NodeGroupMembership.count.should == 0
    end
  end
end
