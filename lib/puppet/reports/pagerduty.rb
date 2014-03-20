require 'puppet'
require 'json'
require 'yaml'

begin
  require 'redphone/pagerduty'
rescue LoadError => e
  Puppet.info "You need the `redphone` gem to use the PagerDuty report"
end

Puppet::Reports.register_report(:pagerduty) do

  config_file = File.join(File.dirname(Puppet.settings[:config]), "pagerduty.yaml")
  raise(Puppet::ParseError, "PagerDuty report config file #{config_file} not readable") unless File.exist?(config_file)
  config = YAML.load_file(config_file)
  PAGERDUTY_API = config[:pagerduty_api]

  desc <<-DESC
  Send notification of failed reports to a PagerDuty service. You will need to create a receiving service
  in PagerDuty that uses the Generic API and add the API key to configuration file.
  DESC

  def process
    if self.status == "failed"
      Puppet.debug "Sending status for #{self.host} to PagerDuty."
      details = Array.new
      self.logs.each do |log|
        details << log
      end
      response = Redphone::Pagerduty.trigger_incident(
        :service_key => PAGERDUTY_API,
        :incident_key => "puppet/#{self.host}",
        :description => "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}",
        :details => details
      )
      case response['status']
      when "success"
        Puppet.debug "Created PagerDuty incident: puppet/#{self.host}"
      else
        Puppet.warning "Failed to create PagerDuty incident: puppet/#{self.host}"
      end
    end
  end
end
