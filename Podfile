# Uncomment this line to define a global platform for your project
# platform :ios, '10.0'

target 'Heart Up' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Heart Up
  pod 'Realm'
  pod 'RealmSwift'
  pod 'Charts', :git => 'https://github.com/danielgindi/Charts.git', :branch => 'master'

  target 'Heart UpTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Heart Up WatchKit App' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Heart Up WatchKit App
  

end

target 'Heart Up WatchKit Extension' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Heart Up WatchKit Extension
  pod 'Realm'
  pod 'RealmSwift'
  
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
