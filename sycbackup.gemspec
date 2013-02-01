Gem::Specification.new do |s|
  s.name         = "syc-backup"
  s.summary      = "Back up database and files or schedule cron job for backup"
  s.description  = "Back up database and files or schedule cron job for backup"
  s.requirements = ['No requirements']
  s.version      = "0.0.3"
  s.author       = "Pierre Sugar"
  s.email        = "pierre@sugaryourcoffee.de"
  s.homepage     = "http://syc.dyndns.org/drupal"
  s.platform     = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files        = Dir['**/**']
  s.executables  = ['sycbackup']
  s.test_files   = Dir['test/test*.rb']
  s.has_rdoc     = true
end
