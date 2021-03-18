require "rails_helper"

Dir[File.join(__dir__, "features/support/**/*.rb")].sort.each { |file| require file }

WebMock.allow_net_connect!
