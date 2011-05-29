require 'puppet'
require 'json'
require 'yaml'

begin
  require 'rest_client'
rescue LoadError => e
  Puppet.info "You need the `rest-client` gem to use the PagerDuty report"
end

Puppet::Reports.register_report(:pagerduty) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "pagerduty.yaml"])
  raise(Puppet::ParseError, "PagerDuty report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  PAGERDUTY_API = config[:pagerduty_api]

  desc <<-DESC
  Send notification of failed reports to a PagerDuty service. You will need to create a receiving service 
  in PagerDuty that uses the Generic API and add the API key to configuration file.
  DESC

  def process
    if self.status == 'failed'
      Puppet.debug "Sending status for #{self.host} to PagerDuty."
      payload = {}
      payload = { :service_key => "#{PAGERDUTY_API}", :event_type => "trigger",
                  :description => "Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}" }
      RestClient.post "https://events.pagerduty.com/generic/2010-04-15/create_event.json", payload.to_json, :content_type => :json, :accept => :json
    end
  end
end
