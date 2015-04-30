Pod::Spec.new do |s|
  s.name             = "ApplicationInsights"
  s.version          = "1.0-alpha.1"
  s.summary          = "Microsoft Application Insights SDK for OSX"
  s.description      = <<-DESC
                       Application Insights is a service that allows developers to keep their applications available, performant, and successful. 
                       This SDK will allow you to send telemetry of various kinds (event, trace, exception, etc.) and useful crash reports to the Application Insights service where they can be visualized in the Azure Portal.
                       DESC
  s.homepage         = "https://github.com/Microsoft/ApplicationInsights-OSX/"
  s.license          = { :type => 'MIT', :file => 'ApplicationInsights/LICENSE' }
  s.author           = { "Microsoft" => "appinsights-ios@microsoft.com" }

  s.source           = { :http => "https://github.com/Microsoft/ApplicationInsights-OSX/releases/download/v#{s.version}/ApplicationInsights-#{s.version}.zip" }

  s.platform        = :osx, '10.8'
  s.requires_arc    = true

  s.ios.vendored_frameworks = 'ApplicationInsights/ApplicationInsights.framework'
  s.preserve_path   = 'ApplicationInsights/README.md'
end
