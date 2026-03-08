defmodule PinchflatWeb.ApiDocsController do
  @moduledoc """
  Controller for serving the Scalar API documentation UI.
  """

  use PinchflatWeb, :controller

  # sobelow_skip ["XSS.SendResp"]
  def index(conn, _params) do
    html = """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Pinchflat API Documentation</title>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </head>
      <body>
        <script
          id="api-reference"
          type="application/json"
          data-url="/api/spec"
          data-theme="default"
        ></script>
        <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end
end
