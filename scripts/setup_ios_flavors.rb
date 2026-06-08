require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

flavors = ['consumer', 'customer']
base_configs = ['Debug', 'Release', 'Profile']

puts "Syncing build configurations..."

flavors.each do |flavor|
  base_configs.each do |base_name|
    config_name = "#{base_name}-#{flavor}"
    type_sym = base_name == 'Debug' ? :debug : :release
    
    # 1. Project level configurations
    base_proj_config = project.build_configurations.find { |c| c.name == base_name }
    proj_config = project.build_configurations.find { |c| c.name == config_name } || project.add_build_configuration(config_name, type_sym)
    
    # Copy settings from base project config
    proj_config.build_settings.merge!(base_proj_config.build_settings)
    
    # 2. Target level configurations
    project.targets.each do |target|
      base_target_config = target.build_configurations.find { |c| c.name == base_name }
      target_config = target.build_configurations.find { |c| c.name == config_name } || target.add_build_configuration(config_name, type_sym)
      
      # Copy settings from base target config
      target_config.build_settings.merge!(base_target_config.build_settings)
      
      # Assign the flavor-specific .xcconfig
      config_file_path = "Flutter/#{config_name}.xcconfig"
      file_ref = project.files.find { |f| f.path == config_file_path } || project.new_file(config_file_path)
      
      target_config.base_configuration_reference = file_ref
      
      # Project config also needs the ref (though targets usually override it)
      proj_config.base_configuration_reference = file_ref

      puts "Synced #{config_name} for target #{target.name}"
    end
  end
end

project.save
puts "Project saved and synced. Setup complete!"
