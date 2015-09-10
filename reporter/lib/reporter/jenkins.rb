module Jenkins
  module Translate
    GITHUB = {
      'ABORTED' => 'error',
      'FAILURE' => 'failure',
      'NOT_BUILT' => 'error',
      'SUCCESS' => 'success',
      'UNSTABLE' => 'failure'
    }

    def self.to_github(status)
      GITHUB.fetch status, 'pending'
    end
  end
end
