# frozen_string_literal: true

module LoadFixtureHelper
  def load_fixture(name)
    File.read(File.expand_path("../fixtures/#{name}", __dir__))
  end
end
