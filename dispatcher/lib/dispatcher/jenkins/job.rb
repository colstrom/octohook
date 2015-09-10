require 'contracts'

module Jenkins
  class Job
    include Contracts

    Contract Hash => Any
    def initialize(spec)
      @spec = spec
    end

    Contract None => String
    def url
      @url ||= "#{ENV['JENKINS_BASE_URL']}/#{@spec['job']}/buildWithParameters"
    end

    Contract None => Hash
    def parameters
      @parameters ||= {
        token: ENV['JENKINS_SECRET'],
        cause: 'Webhook',
        STACKATO_RELEASE_IDENTIFIER: @spec['head_sha'],
        USING_BRANCH: @spec['head_ref'],
        DESCRIPTION: @spec['description']
      }
    end
  end
end
