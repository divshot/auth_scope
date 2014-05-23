class AuthScope
  def initialize(scopes_string)
    @tree = {}
    scopes_string.split(" ").each{|s| add(s) }
  end
  
  def add(scope_string)
    roots = [@tree]
    
    scope_string.split(":").each do |parts|
      roots = parts.split(",").map do |part|
        roots.map{|r| r[part.to_sym] ||= {}; r[part.to_sym]}
      end.flatten
    end
  end
  
  def can?(*args)
    subject = subject.respond_to?(:to_scope) ? subject.to_scope : subject.to_s
    parts = args.map{|arg| arg.respond_to?(:to_scope) ? (arg.to_scope : arg.to_s).split(":") }.flatten.map(&:to_sym)
    root = @tree
    parts.each do |part|
      return true if root != @tree && root == {}
      return false if !root.key?(part) && root != {}
      root = root[part]
    end
    true
  end
end

require "auth_scope/version"