
module Puppet::Parser::Functions
  newfunction(:role_addresses, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    if (args.is_a? String)
      args = [args]
    end
    role = args[0]
    #addresses = lookupvar("role_#{role}").split(",")
    addresses = function_extlookup(["truth/role_#{role}", []])
    return addresses
  end # puppet function role_addresses
end # module Puppet::Parser::Functions
