# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'WyHelperComponents' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # 消除Pods下所有第三方库在编译时的警告
  inhibit_all_warnings!

  # Pods for WyHelperComponents

  pod 'SDWebImage', '5.19.7'
  pod 'Masonry', '1.1.0'
  pod 'MBProgressHUD',:git => 'https://github.com/jdg/MBProgressHUD.git'
  pod 'MJRefresh','3.7.8'
  pod 'YYModel', '1.0.4'
  pod 'YYText', '1.0.7'
  pod 'YYCategories', '1.0.4'
  pod 'WCDB.objc', '~> 2.1.10'
  pod 'IQKeyboardManager', '6.5.19'

  # svga动画被压缩问题修复
  pod 'SVGAPlayer',:git => 'https://github.com/bxxmwys/SVGAPlayer-iOS.git'
  pod 'Protobuf', '3.25.3'
  
  # 部分动画使用lottie实现
  pod 'lottie-ios', '~> 2.5.3'

  #RAC
  pod 'ReactiveObjC', '3.1.1'

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      # 适配iOS16
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
    end
  end
end
