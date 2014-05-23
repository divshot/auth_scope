require 'spec_helper'

describe AuthScope do
  subject{ AuthScope.new(@scope || "user:email") }
  
  describe '#can?' do
    it 'should authorize for any segment of a chain' do
      @scope = "foo:bar:baz"
      should_authorize "foo"
      should_authorize "foo:bar"
      should_authorize "foo:bar:baz"
    end
    
    it 'should not work for a non-specified subsegment' do
      @scope = "user:read"
      should_not_authorize "user:write"
    end
    
    it 'should not work for a deeper namespace' do
      @scope = "user"
      should_not_authorize "user:write"
    end
    
    it 'should work from multiple defined scopes' do
      @scope = "user apps"
      should_authorize "user"
      should_authorize "apps"
    end
    
    context 'wildcards' do
      it 'should allow wildcards to represent any scope' do
        @scope = "user:*"
        should_authorize "user:email"
        should_authorize "user:write"
      end

      it 'should not grant multi-level authorization with wildcards' do
        @scope = "user:*"
        should_not_authorize "user:write:another"
      end

      it 'should work with lower namespaces and wildcards' do
        @scope = "user:*:write"
        should_authorize "user:bob:write"
        should_authorize "user:frank:write"
        should_not_authorize "user:bob:read"
      end
    end
    
    context 'batch delimiter' do
      it 'should work for each specified in the batch' do
        @scope = "user,app:write"
        should_authorize "user:write"
        should_authorize "app:write"
        should_not_authorize "book:write"
      end
      
      it 'should work on multiple levels' do
        @scope = "user,app:read,write"
        should_authorize "user:write"
        should_authorize "app:read"
      end
    end
    
    context 'global wildcards' do
      it 'should work for any level of specificity' do
        @scope = "user:**"
        should_authorize "user:abc:write:foo"
      end
      
      it 'should work as a catch-all if supplied alone' do
        @scope = "**"
        should_authorize "foo:bar:baz"
      end
    end
  end
  
  describe '#any?' do
    it 'should authorize any of the supplied scopes' do
      @scope = "user:foo:write"
      expect(subject).to be_any('user:foo:write', 'admin')
    end
  end
  
  describe '#all?' do
    it 'should authorize only with ALL of the supplied scopes' do
      @scope = "user admin"
      expect(subject).to be_all("user", "admin")
      expect(subject).not_to be_all("user", "bork")
    end
  end
end