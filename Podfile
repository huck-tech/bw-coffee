# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

def shared_pods
    pod 'SwiftyJSON'
    pod 'Classy'
    pod 'CorePlot'
    pod 'Alamofire'
    pod 'SwiftyBluetooth'
    pod 'SwiftState', :git => 'https://github.com/ReactKit/SwiftState.git', :commit => '55418070f9dcb289e7e8d9d6c463b1a8c3bac228'
    pod 'SnapKit'
    pod 'Cartography'
    pod 'Heap'
    pod 'DatePickerDialog'
    pod 'SwiftDate'
    pod 'Parse'
    pod 'Pages'
    pod 'SwiftyAttributes'
    pod 'UIView+draggable'
    pod 'mailgun'
    pod 'MessengerKit', :git => 'https://github.com/steve228uk/MessengerKit.git'
    pod 'Braintree'
    pod 'Locksmith'
    pod 'IQKeyboardManagerSwift'
    pod 'NotificationBannerSwift'
    pod 'Cloudinary'
    pod 'AlamofireImage'
    pod 'OneSignal'
    pod 'Eureka'
    pod 'MBProgressHUD'
end

target 'HeavyBean' do
    pod 'SwiftyJSON'
    pod 'Alamofire'
    pod 'AwaitKit'
    pod 'IQKeyboardManagerSwift'
    pod 'mailgun'
end

target 'Device Control' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    
    # Pods for Bellwether Coffee
    shared_pods
end

target 'Bellwether Coffee' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  pod 'PayPalHereSDK', :git => 'https://github.com/bellwethercoffee/paypal-here-sdk-ios-distribution.git'

  # Pods for Bellwether Coffee
  shared_pods
  
  target 'Bellwether CoffeeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Bellwether CoffeeUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
