Gem::Specification.new do |s|
  s.name         = 's3-mysql-backup'
  s.version      = '1.0.5'
  s.date         = '2013-04-07'
  s.summary      = "Simple mysql backup to S3"
  s.description  = "A simple mysql backup to Amazon S3"
  s.authors      = ["Jeff Emminger"]
  s.email        = 'jeff@7compass.com'
  s.files        = Dir['lib/*'] << 'README.md'
  s.homepage     = 'https://github.com/7compass/s3-mysql-backup'
  s.platform     = Gem::Platform::RUBY
  s.require_path = '.'
  s.require_paths << 'lib'

  s.executables  = "s3-mysql-backup"

  s.add_runtime_dependency('aws-s3', [">= 0"])

  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'rr', '~> 1.0.5'
  s.add_development_dependency 'fakefs', '~> 0.4.2'

  s.test_files  = Dir.glob("spec/**/*.rb")

end
