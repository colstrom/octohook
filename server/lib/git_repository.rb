require 'rugged'

REPOSITORY_PATH = ENV.fetch('REPOSITORY_PATH').freeze

module GitRepository
  def repository
    Rugged::Repository.new REPOSITORY_PATH
  end
end
