# frozen_string_literal: true

yaml_path = Rails.root.join("config/redis/shared.yml")
unless yaml_path.exist?
  say "Adding `config/redis/shared.yml`"
  empty_directory yaml_path.parent.to_s
  copy_file "#{__dir__}/shared.yml", yaml_path
end
