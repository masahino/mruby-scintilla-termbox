MRuby::Build.new do |conf|
  conf.toolchain :clang
  conf.gembox 'default'

  conf.gem File.expand_path(File.dirname(__FILE__))

  conf.enable_test
end
