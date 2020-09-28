platform :ios, '12.0'
use_frameworks!

target 'Cell Animations' do
  pod 'SnapKit', '~> 5.0.1'
end

target 'Sticky Headers' do
  pod 'SnapKit', '~> 5.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
