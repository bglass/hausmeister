require_relative '../../../app/models/node.rb'
require 'spec_helper'

RSpec.describe Node do

  describe "::types" do
    it "delivers the node types" do
      number_of_ntypes = Nodetype.all.size
      Nodetype.create(name: "RSPEC_UNIT_TEST_DUMMY")

      expect(Nodetype.all.size).to eq(number_of_ntypes + 1)
      expect(Nodetype.find("RSPEC_UNIT_TEST_DUMMY").name).to eq("RSPEC_UNIT_TEST_DUMMY")

      Nodetype.destroy("RSPEC_UNIT_TEST_DUMMY")
    end
  end

  describe "::object_undefined?" do
    context "when type is known" do
      it "responds with false" do
        expect(Node.object_undefined? "Object").to eq(false)
      end
    end
    context "when type is unknown" do
      it "responds with true" do
        expect(Node.object_undefined? "NON_EXISTING_TYPE").to eq(true)
      end
    end
  end

  describe "::create_subclasses" do
    it "creates subclasses of Node" do
      allow(Node).to receive_messages(:types => ["Dummy1", "Dummy2"])
      obj = Node.create_subclasses
      expect(obj).to be_a(Array)
      expect(obj.size).to eq(2)
      expect(obj[0]).to be_a(Class)
      expect(obj[1]).to be_a(Class)
      expect(obj[0].name).to eq("Dummy1")
      expect(obj[1].name).to eq("Dummy2")
      expect(obj[0].superclass.name).to eq("Node")
    end
  end


  describe "::create_reference_methods" do
    it "creates access methods for cross references" do
      allow(Node).to receive(:types){["Dummy3", "Dummy4"]}
      allow(Node).to receive(:find_ref){ |arg| arg }
      allow(Referencetype).to receive(:pluck) {[["Dummy3","RefMethod3"],["Dummy4","RefMethod4"]]}
      Node.create_subclasses
      Node.create_reference_methods
      d3 = Dummy3.new(content: {"RefMethod3" => "result3"})
      d4 = Dummy4.new(content: {"RefMethod4" => "result4"})
      expect(d3.refmethod3).to eq("result3")
      expect(d4.refmethod4).to eq("result4")
    end
  end

  describe "::find_xid" do
    it "returns node by id" do
      xid    = 2147483645
      pid    = 8927979
      x = Node.find_or_create_by(idx: xid)
      x.update(xparent: pid, xtype: "Node")
      n = Node.find_xid(xid)
      expect(n.xparent).to eq(pid)
      Node.find(xid).destroy
    end
  end


  describe "::find_ref" do
    before(:all) do
        @ref = "RSPEC_DUMMY_REF"
        @xid    = 2147483645
        Idx.find_or_create_by(idk: @ref, idx: @xid)
    end
    after(:all) do
        Idx.destroy(@ref)
    end

    context "when reference is known" do
      it "returns node by text reference" do
        allow(Node).to receive(:find_xid) { |arg| arg }
        expect(Node.find_ref(@ref)).to eq(@xid)
      end
    end
    context "when reference is unknown" do
      it "returns nil" do
        allow(Node).to receive(:find_xid) { |arg| arg }
        expect(Node.find_ref("Unknown_Reference")).to eq(nil)
      end
    end
  end

  #####  instance methods  #################################

  # describe "#content_length" do
  #   it "returns the number of fields in the content" do
  #     xid    = 2147483645
  #     n = Node.find_or_create_by(idx: xid)
  #     n.content["a"]="b"
  #     n.content["c"]="d"
  #     n.content["e"]="f"
  #     expect(n.content_length).to eq(3)
  #     n.destroy
  #   end
  # end


  describe "#subclass" do
    it "adjusts an object's class according to its xtype" do
      xid    = 2147483645
      allow(Node).to receive(:types)    {["Dummy5"]}
      Node.create_subclasses
      n = Node.find_or_create_by(idx: xid)
      n.update(xtype: "Dummy5")
      expect(n.subclass).to be_an_instance_of(Dummy5)
      n.destroy
    end
  end

  describe "#children_follow_references" do
    #TBD
  end


  describe "#children" do
    it "returns array of node's children" do
      range = (2147483642..2147483645)
      range.each {|i| Node.destroy(i) if Node.exists?(i) }
      n = Node.create(idx: 2147483645)
      c1 = Node.create(idx: 2147483644, xparent: 2147483645, xtype: "Node")
      c2 = Node.create(idx: 2147483643, xparent: 2147483645, xtype: "Node")
      c3 = Node.create(idx: 2147483642, xparent: 2147483645, xtype: "Node")
      x = [2147483644,2147483643,2147483642].sort
      c = n.children.sort
      expect(c[0].idx).to eq(x[0])
      expect(c[1].idx).to eq(x[1])
      expect(c[2].idx).to eq(x[2])
      range.each {|i| Node.destroy(i) if Node.exists?(i) }
    end
  end

  describe "#parent" do
    it "returns node's parent" do
      range = (2147483642..2147483645)
      range.each {|i| Node.destroy(i) if Node.exists?(i) }

      n = Node.create(idx: 2147483642, xparent: 2147483645, xtype: "Node")
      p = Node.create(idx: 2147483645, xtype: "Node")

      expect(n.parent.idx).to eq(p.idx)
      n.destroy
      p.destroy
    end
  end

  describe "#reference" do
    it "returns the referred node" do
      range = (2147483642..2147483645)
      range.each {|i| Node.destroy(i) if Node.exists?(i) }

      i = Idx.create(idk: "RSPEC_DUMMY_REFID", idx: 2147483644)
      n = Node.create(idx: 2147483642, refid: "RSPEC_DUMMY_REFID", xtype: "Node")
      r = Node.create(idx: 2147483644, xtype: "Node")

      expect(n.reference.idx).to eq(r.idx)

      i.destroy
      n.destroy
      r.destroy
    end
  end


  describe "#is_reference?" do
    it "returns a boolean result" do
      n = Node.new(idx:2147483644)
      m = Node.new(idx:2147483645, refid: "DUMMY")
      expect(n.is_reference?).to eq(nil)
      expect(m.is_reference?).to eq(true)
      m.destroy
      n.destroy
    end
  end


  describe "#summary" do
    it "return a human readable summary" do
      n = Node.new(idx:2147483644, xtype: "Dummy")
      expect(n.summary).to be_a(String)
      expect(n.summary.length).to be > 0
      n.destroy
    end
  end
end
