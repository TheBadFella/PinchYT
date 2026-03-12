defmodule PinchflatWeb.Api.SearchController do
  use PinchflatWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema
  alias Pinchflat.Media
  alias PinchflatWeb.Schemas

  @default_limit 50

  tags(["Search"])

  operation(:search,
    operation_id: "Api.SearchController.search",
    summary: "Search media items",
    description: "Search for media items by title",
    parameters: [
      q: [in: :query, description: "Search query", schema: %Schema{type: :string, example: "my video"}, required: true],
      limit: [
        in: :query,
        description: "Maximum number of results",
        schema: %Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
      ]
    ],
    responses: [
      ok: {"Search results", "application/json", Schemas.SearchResponse}
    ]
  )

  def search(conn, params) do
    search_term = Map.get(params, "q", "")
    limit = parse_int(Map.get(params, "limit", "#{@default_limit}"), @default_limit)

    search_results = Media.search(search_term, limit: limit)

    conn
    |> put_status(:ok)
    |> json(%{data: search_results, query: search_term})
  end

  defp parse_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_int(value, _default) when is_integer(value), do: value
  defp parse_int(_, default), do: default
end
