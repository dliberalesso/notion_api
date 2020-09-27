defmodule NotionAPI.Client do
  alias Finch.Response

  def child_spec do
    {Finch,
     name: __MODULE__,
     pools: %{
      :default => [size: 10],
       "https://www.notion.so/" => [size: 32, count: 8]
     }}
  end

  def post(path, body) do
    url = "https://www.notion.so/api/v3/#{path}"
    headers = [
      {"content-type", "application/json"},
      # TODO: Get token
      {"cookie", "token_v2=token_v2"}
    ]

    :post
    |> Finch.build(url, headers, body)
    |> Finch.request(__MODULE__)
  end

  def load_page_chunk(id) do
    path = "loadPageChunk"
    body = Jason.encode!(%{
      "pageId" => "#{id}",
      "limit" => 50,
      "cursor" => %{"stack" => []},
      "chunkNumber" => 0,
      "verticalColumns" => false
    })

    post(path, body)
    |> handle_response()
  end

  defp handle_response({:ok, %Response{body: body}}) do
    {:ok, Jason.decode!(body)["recordMap"]}
  end
end
