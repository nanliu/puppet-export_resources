require 'yaml'
require 'fileutils'

Puppet::Parser::Functions::newfunction(:export_resources, :doc => '
Export a hash to yaml file intended for consumption to create_resource or create_virtual_resource.
Takes three parameters:
  export_resource($file_path, $title, $parameter)
    Export resources in the following hash format:
     {title=>{parameters}}
    In terms of merge_option, supports merge, replace.
') do |args|
  raise ArgumentError, ("export_resource(): wrong number of arguments (#{args.length}; must be 3)") if args.length != 3
  path = args[0]
  title = args[1]
  param = args[2]

  FileUtils.mkdir_p(path) unless File.exists?(path)
  raise Puppet::Error, 'export_resource:: #{path} is not a directory.' unless File.directory?(path)

  file = File.join(path, "#{title}.yaml")
  metadata = "# export_resource system: #{lookupvar('clientcert')} config: #{catalog.version}"
  if File.exists?(file) then
    # do some comparison then write data.
    current = YAML.load_file(file)
    if Marshal.dump(current) != Marshal.dump(param) then
      File.open(file, 'w') do |f|
        f.puts metadata
        f.puts param.to_yaml
      end
    end
  else
    File.open(file, 'w') do |f|
      f.puts metadata
      f.puts param.to_yaml
    end
  end

end
