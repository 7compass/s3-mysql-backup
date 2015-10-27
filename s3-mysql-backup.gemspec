Gem::Specification.new do |s|
  s.name         = "s3-mysql-backup"
  s.version      = "2.2.2"
  s.date         = Date.today
  s.summary      = "Simple mysql backup to S3"
  s.description  = "A simple mysql backup to Amazon S3"
  s.authors      = ["Jeff Emminger"]
  s.email        = "jeff@7compass.com"
  s.files        = Dir["lib/*"] << "README.md"
  s.homepage     = "https://github.com/7compass/s3-mysql-backup"
  s.platform     = Gem::Platform::RUBY
  s.require_path = "."
  s.require_paths << "lib"

  s.executables  = "s3-mysql-backup"

  s.add_runtime_dependency("aws-sdk", ["~> 1.37"])

  s.add_development_dependency "rspec", "~> 2.12"
  s.add_development_dependency "rr", "~> 1.0"

  s.test_files  = Dir.glob("spec/**/*.rb")

  s.license = "MIT"
end
