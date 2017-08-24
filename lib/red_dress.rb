require_relative 'red_dress/glitch'
require_relative 'red_dress/loophole'
require_relative 'red_dress/sentinel'
require_relative 'red_dress/sniffer'

module RedDress
  @@routes_uri = 'http://challenge.distribusion.com/the_one/routes'
  @@passphrase = nil

  def self.passphrase=(passphrase)
    @@passphrase = passphrase
  end

  def self.passphrase
    @@passphrase
  end

  def self.routes_uri=(base_uri='')
    @@routes_uri = base_uri
  end

  def self.routes_uri
    @@routes_uri
  end

  def self.upload_all_routes
    passphrase ||= @@passphrase
    raise Glitch.new('Passphrase not provided. Trap assumed.') unless passphrase

    # Iterate over each source type here. They must all follow a common interface.
    [RedDress::Sentinel.new].each do |source|
      source.get_routes
      source.upload_routes
    end
  end

  def self.to_utc(time)
    t = DateTime.parse(time).to_time.utc.strftime("%Y-%m-%dT%H:%M:%S").to_s
    t
  end
end
