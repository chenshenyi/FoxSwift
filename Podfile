# Uncomment the next line to define a global platform for your project
platform :ios, '16.4'

target 'FoxSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for FoxSwift
  pod 'Kingfisher'
  pod 'WebRTC-lib'
  pod "ESPullToRefresh"
  pod 'Alamofire'
  pod "FirebaseFirestore"
  pod "FirebaseFirestoreSwift"
  pod "FirebaseStorage"
  pod "SnapKit"
  pod "IQKeyboardManager"
  
  # Debug Only
  pod "SwiftLint", :configurations => ['Debug']

  target 'FoxSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FoxSwiftUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
        end
      end
    end
  end
end
