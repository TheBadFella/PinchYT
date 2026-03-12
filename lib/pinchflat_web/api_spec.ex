defmodule PinchflatWeb.ApiSpec do
  @moduledoc """
  OpenAPI 3.0 specification for the Pinchflat API.
  Collects operations from controller @operation decorators.
  """

  alias OpenApiSpex.{Info, OpenApi, Server}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "Pinchflat API",
        version: "1.0.0",
        description: "API for accessing Pinchflat media management data"
      },
      servers: [
        %Server{
          url: "/",
          description: "Current server"
        }
      ],
      # Paths will be populated by OpenApiSpex.Plug.PutApiSpec from router + controller operations
      paths: collect_paths()
    }
    # resolve_schema_modules/1 processes schema references and builds the full spec
    |> OpenApiSpex.resolve_schema_modules()
  end

  # Collect all paths from routed controllers with @operation decorators
  defp collect_paths do
    PinchflatWeb.Router.__routes__()
    |> Enum.filter(fn route -> has_operation?(route) end)
    |> Enum.reduce(%{}, fn route, acc ->
      path = route_to_path(route.path)
      method = String.downcase(to_string(route.verb)) |> String.to_atom()

      case get_operation(route.plug, route.plug_opts) do
        nil -> acc
        operation -> Map.update(acc, path, %{method => operation}, &Map.put(&1, method, operation))
      end
    end)
    |> Enum.into(%{}, fn {path, operations} ->
      path_item = struct(OpenApiSpex.PathItem, operations)
      {path, path_item}
    end)
  end

  defp route_to_path(path) do
    path
    |> String.replace(~r/:([^\/]+)/, "{\\1}")
  end

  defp has_operation?(route) do
    Code.ensure_loaded?(route.plug) and function_exported?(route.plug, :open_api_operation, 1)
  end

  defp get_operation(plug, plug_opts) do
    if function_exported?(plug, :open_api_operation, 1) do
      try do
        plug.open_api_operation(plug_opts)
      rescue
        _ -> nil
      end
    else
      nil
    end
  end
end
