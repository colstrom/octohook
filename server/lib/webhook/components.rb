require 'contracts'
require_relative 'config'

module Components
  include Contracts

  # Returns a table of { component_path => jenkins_job } mappings.
  Contract None => HashOf[String, String]
  def self.table
    @table ||= CONFIG['components']
  end

  # Given a list of changed files, return the components that changed.
  Contract ArrayOf[String] => ArrayOf[String]
  def self.changed(changed_files)
    table.keys.select do |path|
      changed_files.any? { |filename| filename.start_with? path }
    end
  end

  # Given a list of changed components, return a human-friendly list.
  Contract ArrayOf[String] => ArrayOf[String]
  def self.humanize(changed_components)
    changed_components.map do |name|
      name.sub(%r{^src/(services/)?}, '').sub(/_ng$/, '').sub('_', ' ')
    end
  end
end
