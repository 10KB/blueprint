namespace :whiteprint do
  task migrate: :environment do
    Whiteprint::Migrator.interactive
  end
end
