defmodule PinchflatWeb.ApiSpecController do
  @moduledoc """
  Controller for serving the OpenAPI specification.
  """

  use PinchflatWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema

  tags(["System"])

  operation(:spec,
    operation_id: "ApiSpecController.spec",
    summary: "OpenAPI specification",
    description: "Returns the OpenAPI 3.0 specification document for this API",
    responses: [
      ok: {
        "OpenAPI specification JSON",
        "application/json",
        %Schema{type: :object, description: "OpenAPI 3.0 specification"}
      }
    ]
  )

  def spec(conn, _params) do
    spec =
      PinchflatWeb.ApiSpec.spec()
      |> OpenApiSpex.OpenApi.to_map()

    conn
    |> put_status(:ok)
    |> put_resp_header("content-type", "application/json")
    |> json(spec)
  end
end
