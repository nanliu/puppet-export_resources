require 'yaml'
require 'fileutils'

Puppet::Parser::Functions::newfunction(:export_resources, :doc => '
Export a hash to a file in yaml intended for consumption to create_resource or create_virtual_resource.
Takes three parameters:
  export_resource($path, $title, $parameter)
    Export resources to /${path}/${title}.yaml with parameter hash converted to yaml:
') do |args|
  raise Puppet::ParseError, "export_resources(): wrong number of arguments #{args.length}, expecting (path, title, param)." if args.length != 3
  path = args[0]
  title = args[1]
  param = args[2]

  raise Puppet::ParseError, "export_resources(): path #{path} is not absolute." unless path == File.expand_path(path)
  raise Puppet::ParseError, "export_resources(): param type recieved #{param.class}, expecting Hash." unless param.is_a? Hash

  FileUtils.mkdir_p(path) unless File.exists?(path)

  raise Puppet::Error, "export_resource(): path #{path} is not a directory." unless File.directory?(path)
  file = File.join(path, "#{title}.yaml")

  metadata = "# export_resource\n# system: #{lookupvar('clientcert')}\n# config: #{catalog.version}"

  # TODO: support noop
  if File.exists?(file) then
    # compare current file and only update
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
