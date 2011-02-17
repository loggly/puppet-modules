# These files below appear automatically on all rightscale machines.
# Parse them and make facts like 'ec2_instance_id' etc
paths = [ "/var/spool/ec2/meta-data-cache.rb", "/var/spool/ec2/user-data.rb" ]

paths.each do |path|
  if File.exists?(path)
    require path
    ENV.each do |name, value|
      next unless name =~ /^(EC2_|RS_)/
      Facter.add(name) do
        setcode do
          value
        end # setcode
      end # Facter.add
    end # ENV.each
  end # if !File.exists?
end # paths.each 
