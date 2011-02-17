# Add a puppet parser function called 'role_enabled'
#   * Takes 1 argument, the role name.
#   * Expects a extlookup value truth/server_tags to be an array of tags
#
# We use rightscale, which supports "tagging" a server with any number of tags
# The tags are of the format: namespace:predicate=value
# http://support.rightscale.com/12-Guides/RightScale_Methodologies/Tagging
#
# Each value in server_tags must be of the format described above.
# Roles are expected to be of format: "role:<role>=true"
# For example, the role 'loadbalancer' is "role:loadbalancer=true"
#     

module Puppet::Parser::Functions
  newfunction(:role_enabled, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    if (args.is_a? String)
      args = [args]
    end
    role = args[0]
    roles = function_extlookup(["truth/server_tags"]).grep(/^role:/)
    roletag_re = /^role:#{role}(?:=.+)?$/
    roletag = roles.grep(roletag_re).first
    return false if roletag.nil?

    key, value = roletag.split("=")
    return value == "true"
  end # puppet function role_enabled
end # module Puppet::Parser::Functions
