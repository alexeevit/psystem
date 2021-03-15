RSpec.configure do |config|
  # Skip assets precompilcation if we exclude system specs.
  # For example, you can run all non-system tests via the following command:
  #
  #    rspec --tag ~type:system
  #
  # In this case, we don't need to precompile assets.
  next if config.filter.opposite.rules[:type] == "feature" || config.exclude_pattern.match?(%r{spec/features})

  config.before(:suite) do
    # We can use webpack-dev-server for tests, too!
    # Useful if you working on a frontend code fixes and want to verify them via system tests.
    if Webpacker.dev_server.running?
      $stdout.puts "\n⚙️  Webpack dev server is running! Skip assets compilation.\n"
      next
    else
      $stdout.puts "\n🐢  Precompiling assets.\n"

      original_stdout = $stdout.clone
      # Use test-prof now 'cause it couldn't be monkey-patched (e.g., by Timecop or similar)
      start = Time.current
      begin
        # Silence Webpacker output
        $stdout.reopen(File.new("/dev/null", "w"))
        # next 3 lines to compile webpacker before running our test suite
        require "rake"
        Rails.application.load_tasks
        Rake::Task["webpacker:compile"].execute
      ensure
        $stdout.reopen(original_stdout)
        $stdout.puts "Finished in #{(Time.current - start).round(2)} seconds"
      end
    end
  end
end
