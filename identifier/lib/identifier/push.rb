require 'github-events/push'
require_relative 'components'

class PushEvent < GitHub::Events::Push
  def changed_components
    Components.changed changed_files
  end

  def job(component)
    {
      'component' => component,
      'job' => Components.table[component],
      'head_sha' => head,
      'head_ref' => base,
      'base_ref' => branch,
      'description' => describe,
      'repository' => repository['full_name']
    }
  end

  def jobs
    changed_components.map { |component| job(component) }
  end

  def describe
    "WebHook triggered by Push of commit #{head} to #{branch}"
  end

  def important?
    %w(master dev).include? branch
  end
end
