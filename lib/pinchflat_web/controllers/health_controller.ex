defmodule PinchflatWeb.HealthController do
  use PinchflatWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias PinchflatWeb.Schemas

  tags(["System"])

  operation(:check,
    operation_id: "HealthController.check",
    summary: "Health check",
    description: "Returns the health status of the application",
    responses: [
      ok: {"Success", "application/json", Schemas.HealthResponse}
    ]
  )

  def check(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
