defmodule PinchflatWeb.ApiSpecHelper do
  @moduledoc """
  Test helpers for validating API responses against OpenAPI schemas.

  This module provides contract testing helpers to ensure API responses
  match their documented OpenAPI schemas, keeping spec and implementation in sync.
  """

  import OpenApiSpex.TestAssertions

  @doc """
  Asserts that a response matches its OpenAPI schema definition.

  ## Parameters

  - `conn` - The connection struct from the test
  - `operation_id` - The operation ID from the @operation decorator (e.g., "Api.MediaController.index")
  - `status` - HTTP status code (default: 200)

  ## Examples

      test "returns list matching schema", %{conn: conn} do
        conn = get(conn, "/api/media")
        assert_response_schema(conn, "Api.MediaController.index")
      end

      test "returns 404 matching schema", %{conn: conn} do
        conn = get(conn, "/api/media/99999")
        assert_response_schema(conn, "Api.MediaController.show", 404)
      end
  """
  def assert_response_schema(conn, operation_id, status \\ 200) do
    conn = %{conn | status: status}
    assert_operation_response(conn, operation_id)
  end
end
