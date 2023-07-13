# frozen_string_literal: true

namespace :kredis do
  desc "Install kredis"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/install.rb",  __dir__)}"
  end
end
