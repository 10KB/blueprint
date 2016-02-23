namespace :blueprint do
  task :migrate do
    Blueprint::Migrator.interactive
  end
end
