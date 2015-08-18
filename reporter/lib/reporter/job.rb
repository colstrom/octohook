class Job
  include Contracts
  include JenkinsSupport

  def initialize(component, build_id)
    @data = jenkins.get(component, build_id)
  end
end
