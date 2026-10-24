require "test_helper"
require "open3"
require "tmpdir"
require "active_model/version"

class RailtieTest < ActiveSupport::TestCase
  setup do
    skip "Active Model runs its load hook from 7.1" if ActiveModel.version < Gem::Version.new("7.1")
  end

  test "an Active Model class can declare Kredis attributes when the app is eager loaded" do
    output = boot_app eager_load: true, after_boot: "puts Person.new.nickname.class"

    assert_equal "Kredis::Types::Scalar", output.lines.last.chomp
  end

  test "booting does not load Active Model to give it Kredis attributes" do
    output = boot_app eager_load: false, after_boot: <<~RUBY
      puts $LOADED_FEATURES.any? { |feature| feature.end_with?("/active_model/model.rb") }
      puts Person.new.nickname.class
    RUBY

    assert_equal [ "false", "Kredis::Types::Scalar" ], output.lines.last(2).map(&:chomp)
  end

  private
    def boot_app(eager_load:, after_boot:)
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p "#{root}/app/models"
        File.write "#{root}/app/models/person.rb", <<~RUBY
          class Person
            include ActiveModel::Model
            kredis_string :nickname, key: "person:nickname"
          end
        RUBY

        File.write "#{root}/boot.rb", <<~RUBY
          require "rails"
          require "active_model/railtie"
          require "action_controller/railtie"
          require "kredis"

          class KredisTestApp < Rails::Application
            config.root = #{root.inspect}
            config.eager_load = #{eager_load}
            config.logger = Logger.new(nil)
            config.secret_key_base = "secret"
          end

          Rails.application.initialize!
          #{after_boot}
        RUBY

        output, status = Open3.capture2e(RbConfig.ruby, "-rbundler/setup", "#{root}/boot.rb")
        assert status.success?, output
        output
      end
    end
end
