require 'csv'
require 'net/http'
require 'zip'

module RedDress
  class Sentinel
    attr_accessor(:routes, :processed_routes)

    def get_routes
      # Get response from sentinels.
      uri = URI(RedDress::routes_uri)
      uri.query = URI.encode_www_form({ passphrase: RedDress::passphrase, source: :sentinels })
      response = Net::HTTP.get_response(uri)

      # Unzip response, parse, process.
      unzip(response) unless response.nil? || response.code.to_i > 200 || response.content_type != 'application/zip'
      @processed_routes = []
      process_routes

      # Make it so...
      @processed_routes
    end

    def upload_route(route)
      # Upload and return single response.
      response = Net::HTTP.post_form(
        URI(RedDress::routes_uri),
        passphrase: RedDress::passphrase,
        source: route[:source],
        start_node: route[:start_node],
        end_node: route[:end_node],
        start_time: RedDress.to_utc(route[:start_time]),
        end_time: RedDress.to_utc(route[:end_time])
      )
    end

    def upload_routes
      # Upload in batch for this Sentinel instance.
      @processed_routes.each do |processed_route|
        upload_route(processed_route)
      end
    end

    private

    def add_processed_route(route_group)
      start_route = route_group.shift
      next_route = route_group.first

      # Add to papertrail payload.
      @processed_routes.push({
        source: :sentinels,
        start_node: start_route['node'],
        end_node: next_route['node'],
        start_time: start_route['time'],
        end_time: next_route['time']
      })

      # Recurse to capture
      add_processed_route(route_group) unless route_group.count == 1
    end

    def route_ids_distinct
      @routes.map { |route| route['route_id'] }.uniq.sort unless @routes.nil?
    end

    def route_group_by_route_id(id)
      @routes.select { |route| route['route_id'] == id }
    end

    def process_routes
      route_ids_distinct.each do |id|
        # Fetch groups for this route_id.
        route_group = route_group_by_route_id(id)

        # Can't upload route without an end node.
        next if route_group.count == 1

        # Sort ascending by index, assuming group order matters.
        route_group.sort_by { |route| route['index'] }

        # Add to payload.
        add_processed_route(route_group)
      end
    end

    def unzip(response)
      # Open string buffer and parse CSV data.
      Zip::File.open_buffer(response.body) do |zib|
        zib.each do |entry|
          input_stream = entry.get_input_stream
          next unless entry.name.include?('sentinels/routes.csv')
          csv_data = CSV.parse(input_stream.read, headers: true, col_sep: ', ')
          @routes = csv_data
        end
      end
    end
  end
end
