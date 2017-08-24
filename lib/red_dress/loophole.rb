require 'json'
require 'net/http'
require 'zip'

module RedDress
  class Loophole
    attr_accessor(:routes, :node_pairs)

    def get_routes
      # Get response from sentinels.
      uri = URI(RedDress::routes_uri)
      uri.query = URI.encode_www_form({ passphrase: RedDress::passphrase, source: :loopholes })
      response = Net::HTTP.get_response(uri)

      # Unzip response, parse, process.
      unzip(response) unless response.nil? || response.code.to_i > 200 || response.content_type != 'application/zip'
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
    end

    private

    def unzip(response)
      # Open string buffer and parse JSON data.
      Zip::File.open_buffer(response.body) do |zib|
        zib.each do |entry|
          input_stream = entry.get_input_stream
          next unless input_stream.is_a?(Zip::InputStream)

          json_data = JSON.parse(entry.get_input_stream.read, headers: true, col_sep: ', ')
          puts json_data
          if entry.name.include?('loopholes/routes.csv')
            @routes = json_data['routes']
            puts @routes
          elsif entry.name.include?('loopholes/note_pairs.csv')
            @node_pairs = json_data['node_pairs']
            puts @node_pairs
          end
        end
      end
    end
  end
end
