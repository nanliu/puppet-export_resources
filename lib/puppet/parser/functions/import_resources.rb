require 'yaml'
Puppet::Parser::Functions::newfunction(:import_resources, :type => :rvalue, :doc => '
Import yaml file(s) intended for consumption for create_resource or create_virtual_resource.
Takes one parameters:
  import_resources($path, $title)
    import resources in the following hash format:
    { title => { parameter1 => value,
                 parameter2 => value,
               }
    }

  This will import the resource matching /path/resource/title.yaml, subdirectories will be loaded as resource attributes. For example:
  /path/f5_pool/%{title}.yaml
  /path/f5_pool/%{title}/
                         %{attribute}.yaml
                         %{param}/
                                  system_a.yaml
                                  system_b.yaml
') do |args|

  param = {}
  raise Puppet::ParseError, "import_resources(): wrong number of arguments #{args.length}, expecting (path, title)." if args.length != 2
  path = args[0]
  title = args[1]

  raise Puppet::ParseError, "import_resources(): path #{path} is not absolute." unless path == File.expand_path(path)
  raise Puppet::Error, "import_resources(): path #{path} is not a directory." unless File.exist?(path) && File.directory?(path)
  Dir.chdir(path)

  res_path = File.join(path, title)
  file = File.join(path,"#{title}.yaml")
  raise Puppet::Error, "import_resources(): file #{file} not available." unless File.exist?(file) && File.file?(file)

  begin
    param = YAML.load_file(file)
  rescue exception => e
    Puppet.warn "Failed to load #{file}: e"
    # TODO: generate a notify resource.
    # p_resource = Puppet::Parser::Resource.new(:notify, file, :scope => self, :source => resource)
    # p_resource.set_parameter("message",e)
    # compiler.add_resource(self, p_resource)
  end

  if File.exist?(res_path) && File.directory?(res_path)
    Dir.chdir(res_path)
    #Disable
    #files = Dir.glob('*') - Dir.glob('*/')
    #
    #files.each do |file|
    #  attr = File.basename(file, '.yaml')
    #  param[attr] = YAML.load_file(file)
    #end

    Dir.glob('*/').each do |dir|
      Dir.chdir(dir)
      attr = dir.chop
      Dir.glob('*.yaml').each do |file|
        record = YAML.load_file(file)

        if param[attr].is_a? Array then
          param[attr] << record
        elsif param[attr].is_a? Hash then
          param[attr] = param[attr].merge(record)
        elsif param[attr].is_a? String then
          param[attr] += record
        elsif param[attr].is_a? NilClass then
          param[attr] = record
        else
          raise Puppet::Error, "import_resource(): does not support #{record.class}."
        end
      end
    end
  else
    param = YAML.load_file(file)
  end

  { title => param }
end
