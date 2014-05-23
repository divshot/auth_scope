class AuthScope
  def initialize(*scopes)
    @tree = {}
    scopes.join(" ").split(" ").each{|s| add(s) }
  end
  
  def add(scope_string)
    roots = [@tree]
    
    scope_string.split(":").each do |parts|
      roots = parts.split(",").map do |part|
        roots.map{|r| r[part.to_s] ||= {}; r[part.to_s]}
      end.flatten
    end
  end
  
  def can?(*args)
    subject = subject.respond_to?(:to_scope) ? subject.to_scope : subject.to_s
    parts = args.map{|arg| (arg.respond_to?(:to_scope) ? arg.to_scope : arg.to_s).split(":") }.flatten.map(&:to_s)
    roots = [@tree]
    parts.each do |part|
      return true if roots.detect{|r| r.key?('**')}
      is_last = part == parts.last
      if roots.detect{|r| r.key?('*')}
        roots = roots.map{|r| [r[part], r['*']].compact }.flatten
      else
        return false unless roots.detect{|r| r.key?(part)}
        roots = roots.map{|r| r[part] }.flatten
      end
    end
    true
  end
  
  def any?(*scopes)
    scopes = scopes.join(" ").split(" ")
    !!scopes.detect{|scope| can?(scope)}
  end
  
  def all?(*scopes)
    scopes = scopes.join(" ").split(" ")
    scopes.each{|scope| return false unless can?(scope) }
    true
  end
end

require "auth_scope/version"