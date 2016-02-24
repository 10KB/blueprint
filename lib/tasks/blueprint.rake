namespace :blueprint do
  task migrate: :environment do
    Blueprint::Migrator.interactive
  end
end
