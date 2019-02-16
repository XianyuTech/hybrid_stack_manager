#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
	s.name             = 'hybrid_stack_manager'
	s.version          = '0.1.0'
	s.summary          = 'hybrid_stack_manager'
	s.description      = '混合栈管理'
	s.homepage         = 'https://github.com/alibaba-flutter/hybrid_stack_manager.git'
	s.license          = { 'type' => 'MIT', 'file' => 'LICENSE'}
	s.author           = { '正物' => 'kang.wang1988@gmail.com' }
	s.source           = { 'git' => 'git@github.com:alibaba-flutter/hybrid_stack_manager.git', 'tag' => '0.1.0' }
	s.source_files = 'Classes/**/*'
	s.public_header_files = 'Classes/**/*.h'
	s.dependency 'Flutter'

	s.ios.deployment_target = '8.0'
end


