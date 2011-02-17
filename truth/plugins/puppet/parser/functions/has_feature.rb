
module Puppet::Parser::Functions
  newfunction(:has_feature, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    if (args.is_a? String)
      args = [args]
    end
    feature = args[0]
    _has_feature = function_extlookup(["feature/#{feature}", "false"])
    return (_has_feature == "true")
  end # puppet function role_addresses
end # module Puppet::Parser::Functions
