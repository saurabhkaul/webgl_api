defmodule WebglApiWeb.HttpClient do
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    IO.puts """
    [HTTP Request] #{DateTime.utc_now()}
    Method: #{method}
    URL: #{url}
    Headers: #{inspect(headers)}
    Body: #{body}
    """

    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, response} = result ->
        IO.puts """
        [HTTP Response] #{DateTime.utc_now()}
        Status: #{response.status_code}
        Body: #{response.body}
        """
        result
      error ->
        IO.puts """
        [HTTP Error] #{DateTime.utc_now()}
        Error: #{inspect(error)}
        """
        error
    end
  end
end