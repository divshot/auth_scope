# AuthScope

AuthScope is a simple library for describing authorization patterns through strings.
It is intended to work in conjunction with (for example) an OAuth 2.0 API.

## Installation

Add this line to your application's Gemfile:

    gem 'auth_scope'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install auth_scope

### Scope Structure

Authorization scope strings look something like this:    

    user:email apps:one,another:read profile:*
    
Spaces delimit individual authorization grants and can be treated as
completely independent of one another. When specified together they are
considered to authorize additively, meaning that authorization is granted
if *any* of the provided scopes are matched.

The `:` or **namespace** delimiter lets you create generic and specific
permissions. `user:email` is more specific than `user` for instance.

The `,` or **batch** delimiter allows you to apply a scope to multiple
resouces at the same namespace level. `user:email,avatar` is equivalent
to asking for a scope of `user:email user:avatar`.

The `*` or **wildcard** is used to indicate permissiveness for a single
namespace. For instance, `user:*` would grant access to `user:email`
but not `user:email:write`.

The `**` or **global wildcard** is used to indicate permissiveness for
any number of namespaces. `**` would grant access to **everything**, and
`user:**:write` would grant access to any `write` permissions, even if
deeply nested.

The more namespaces a scope has, the greater permission it authorizes.
Each segment of a namespace is considered to be granted, so a scope of
`user:email` grants both `user` and `user:email` scopes.

## Usage

In simple terms, you will initialize an AuthScope with a string and query
its authorization using the `can?` method:

```ruby
require 'auth_scope'

scope = AuthScope.new("user:email apps:foo,bar:*")

scope.can? "user:email" # => true
scope.can? "user:write" # => false
scope.can? "apps:foo:write" # => true
```

You may also specify an array of authorization strings. This is treated no
differently than space delimiting:

```ruby
scope = AuthScope.new("user:email", "apps:foo,bar:*")
```

The `any?` method tests a set of potential authorizations to see if any match:

```ruby
scope = AuthScope.new("admin")
scope.any? "user:email", "admin" # => true
```

The `all? method tests that each of a set of authorizations is a match:

```ruby
scope = AuthScope.new("admin")
scope.all? "user:email", "admin" # => false
```

### Object Scopes

It will often be useful for an object to be able to describe its own scope.
AuthScope will call `to_scope` on passed-in arguments before checking them.
For example:

```ruby
class User
  def to_scope
    "user:#{id}"
  end
end

scope = AuthScope.new("user:123:write")
scope.can? user, "write" # => true
scope.can? another_user, "write" # => false
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/auth_scope/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
