defmodule WebglApiWeb.ShaderController do
  use Phoenix.Controller
  alias WebglApiWeb.HttpClient

  def generate(conn, %{"prompt" => prompt}) do
    case generate_shader(prompt) do
      {:ok, shader_code} ->
        json(conn, %{shader_code: shader_code})
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: reason})
    end
  end

  defp generate_shader(prompt) do
    system_prompt = """
        You are an expert in WebGL and GLSL shaders. Generate GLSL shader code based on text descriptions.
        Only return the raw shader code without any explanation or markdown formatting.
        The code should be valid WebGL fragment shader code. Just give the raw shader code, no english.
        """

    body = Jason.encode!(%{
      model: "claude-3-opus-20240229",
      system: system_prompt,
      max_tokens: 1024,
      messages: [
        %{role: "user", content: prompt}
      ]
    })

    headers = [
      {"Content-Type", "application/json"},
      {"x-api-key", System.get_env("ANTHROPIC_API_KEY")},
      {"anthropic-version", "2023-06-01"}
    ]

    case HttpClient.request(:post, "https://api.anthropic.com/v1/messages", body, headers,recv_timeout: :timer.seconds(60)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        case Jason.decode!(resp_body) do
          %{"content" => shader_code} -> {:ok, shader_code}
          _ -> {:error, "Invalid response from AI service"}
        end
      _ ->
        {:error, "Failed to generate shader"}
    end
  end
end

#  defp generate_shader(prompt) do
#    system_prompt = """
#    You are an expert in WebGL and GLSL shaders. Generate GLSL shader code based on text descriptions.
#    Only return the raw shader code without any explanation or markdown formatting.
#    The code should be valid WebGL fragment shader code.
#    """
#
#    case HTTPoison.post("https://api.anthropic.com/v1/messages",
#           Jason.encode!(%{
#             model: "claude-3-opus-20240229",
#             max_tokens: 1024,
#             system: system_prompt,
#             messages: [
#               %{
#                 role: "user",
#                 content: prompt
#               }
#             ]
#           }),
#           [
#             {"Content-Type", "application/json"},
#             {"x-api-key", System.get_env("ANTHROPIC_API_KEY")},
#             {"anthropic-version", "2023-06-01"}
#           ]) do
#      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#        case Jason.decode!(body) do
#          %{"content" => shader_code} -> {:ok, shader_code}
#          _ -> {:error, "Invalid response from AI service"}
#        end
#      error ->
#      IO.puts error
#        {:error, "Failed to generate shader"}
#    end
#  end
