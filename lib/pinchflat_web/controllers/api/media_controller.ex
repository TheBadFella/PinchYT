defmodule PinchflatWeb.Api.MediaController do
  use PinchflatWeb, :controller

  import Ecto.Query, warn: false

  alias Pinchflat.Repo
  alias Pinchflat.Media.MediaItem

  @default_limit 50
  @min_limit 1
  @max_limit 500

  def recent_downloads(conn, params) do
    limit =
      params
      |> Map.get("limit", "#{@default_limit}")
      |> parse_int(@default_limit)
      |> clamp(@min_limit, @max_limit)

    media_items =
      from(mi in MediaItem,
        where: not is_nil(mi.media_downloaded_at),
        order_by: [desc: mi.media_downloaded_at],
        limit: ^limit,
        select: %{
          id: mi.id,
          uuid: mi.uuid,
          title: mi.title,
          media_id: mi.media_id,
          source_id: mi.source_id,
          uploaded_at: mi.uploaded_at,
          media_downloaded_at: mi.media_downloaded_at,
          media_filepath: mi.media_filepath,
          thumbnail_filepath: mi.thumbnail_filepath,
          metadata_filepath: mi.metadata_filepath,
          nfo_filepath: mi.nfo_filepath,
          subtitle_filepaths: mi.subtitle_filepaths
        }
      )
      |> Repo.all()

    conn
    |> put_status(:ok)
    |> json(%{data: media_items})
  end

  defp parse_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  defp parse_int(value, _default) when is_integer(value), do: value
  defp parse_int(_, default), do: default

  defp clamp(value, min_val, max_val) do
    value
    |> Kernel.max(min_val)
    |> Kernel.min(max_val)
  end
end
