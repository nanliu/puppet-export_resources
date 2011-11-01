require 'yaml'
Puppet::Parser::Functions::newfunction(:import_resources, :type => :rvalue, :doc => '
Import yaml file(s) intended for consumption for create_resource or create_virtual_resource.
Takes one parameters:
  import_resources([$file_path])
    import resources in the following hash format:
    { title => { parameter1 => value,
                 parameter2 => value,
               }
    }

  This will import the resource matching /path/resource/title.yaml subdirectories will be loaded as resource attributes. For example:
  /path/f5_pool/%{title}.yaml
  /path/f5_pool/%{title}/
                         %{attribute}.yaml
                         %{param}/
                                  system_a.yaml
                                  system_b.yaml

') do |args|

  param = {}
  raise ArgumentError, "import_resource(): wrong number of arguments (#{args.length}; must be 1)" if args.length != 1
  title = args[0]

  raise Puppet::Error, "import_resource(): import file #{title}.yaml not available." unless File.exist?("#{title}.yaml") && File.file?("#{title}.yaml")

  param = YAML.load_file("#{title}.yaml")

  if File.exist?(title) && File.directory?(title)
    Dir.chdir(title)
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

  { File.basename(title) => param }
end
