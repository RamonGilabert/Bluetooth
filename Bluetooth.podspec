Pod::Spec.new do |s|
  s.name             = "Bluetooth"
  s.summary          = "You need to be careful with a Bluetooth headset. Because some guys look crazy with them."
  s.version          = "0.1.0"
  s.homepage         = "https://github.com/RamonGilabert/Bluetooth"
  s.license          = 'MIT'
  s.author           = { "Ramon Gilabert" => "ramon.gilabert.llop@gmail.com" }
  s.source           = {
    :git => "https://github.com/RamonGilabert/Bluetooth.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/RamonGilabert'

  s.ios.deployment_target = '8.0'

  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
end
