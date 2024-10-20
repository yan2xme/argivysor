def parse_KV_file(file, separator='=')
    if !File.exist?(file)
      return {}
    end
    file_abs_path = File.expand_path(file)
    input = File.readlines(file_abs_path).map { |line| line.strip }
    # Ignore lines that are empty or start with '//'
    input = input.reject { |line| line.start_with?('//') || line.empty? || !line.include?(separator) }
    result = {}
    input.each do |line|
      parts = line.split(separator, 2) # Split each line into exactly two parts
      if parts.length == 2
        result[parts[0]] = parts[1]
      else
        raise "Invalid line format in #{file}: #{line}. Expected format is 'key#{separator}value'."
      end
    end
    result
  end
  
  def flutter_root
    generated_xcode_build_settings = parse_KV_file(File.join(File.dirname(__FILE__), 'Generated.xcconfig'))
    if generated_xcode_build_settings.has_key?('FLUTTER_ROOT')
      return generated_xcode_build_settings['FLUTTER_ROOT'].strip
    end
    raise 'FLUTTER_ROOT not found in Generated.xcconfig. Please ensure Flutter is correctly set up.'
  end
  
  def flutter_ios_podfile_setup
    flutter_application_path = File.expand_path('..', __dir__)
    engine_dir = File.expand_path(File.join(flutter_root, 'bin', 'cache', 'artifacts', 'engine', 'ios'))
    framework_name = 'Flutter'
    local_engine = ENV['FLUTTER_ENGINE']
    if local_engine
      engine_dir = File.expand_path(local_engine)
    end
  
    project_path = File.join(flutter_application_path, '.ios', 'Flutter')
    pod 'Flutter', :path => engine_dir
    pod 'FlutterPluginRegistrant', :path => File.join(project_path, 'FlutterPluginRegistrant')
  end
  
  def flutter_install_all_ios_pods(flutter_application_path)
    flutter_ios_podfile_setup
    generated_xcode_build_settings = parse_KV_file(File.join(flutter_application_path, 'ios', 'Flutter', 'Generated.xcconfig'))
    if generated_xcode_build_settings.empty?
      raise 'Generated.xcconfig must exist. Make sure "flutter pub get" has been run in the project root directory.'
    end
  
    # Add each plugin pod here
    plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
    if File.exist?(plugins_file)
      plugin_pods = parse_KV_file(plugins_file, ':')
      plugin_pods.each do |name, path|
        pod name, :path => File.join(flutter_application_path, path)
      end
    end
  end
  