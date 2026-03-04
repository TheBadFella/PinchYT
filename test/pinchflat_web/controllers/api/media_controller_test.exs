defmodule PinchflatWeb.Api.MediaControllerTest do
  use PinchflatWeb.ConnCase

  import Pinchflat.MediaFixtures

  describe "GET /api/media/recent_downloads" do
    test "returns only downloaded media items", %{conn: conn} do
      downloaded = media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})
      _not_downloaded = media_item_fixture(%{media_downloaded_at: nil})

      conn = get(conn, "/api/media/recent_downloads")
      response = json_response(conn, 200)

      ids = Enum.map(response["data"], & &1["id"])
      assert downloaded.id in ids
      assert length(response["data"]) == 1
    end

    test "returns items ordered by media_downloaded_at descending", %{conn: conn} do
      older = media_item_fixture(%{media_downloaded_at: ~U[2024-01-01 00:00:00Z]})
      newer = media_item_fixture(%{media_downloaded_at: ~U[2024-06-01 00:00:00Z]})

      conn = get(conn, "/api/media/recent_downloads")
      response = json_response(conn, 200)

      ids = Enum.map(response["data"], & &1["id"])
      assert ids == [newer.id, older.id]
    end

    test "default limit is 50", %{conn: conn} do
      for _ <- 1..55 do
        media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})
      end

      conn = get(conn, "/api/media/recent_downloads")
      response = json_response(conn, 200)

      assert length(response["data"]) == 50
    end

    test "respects custom limit param", %{conn: conn} do
      for _ <- 1..10 do
        media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})
      end

      conn = get(conn, "/api/media/recent_downloads?limit=5")
      response = json_response(conn, 200)

      assert length(response["data"]) == 5
    end

    test "clamps limit to minimum of 1", %{conn: conn} do
      media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})
      media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})

      conn = get(conn, "/api/media/recent_downloads?limit=0")
      response = json_response(conn, 200)

      assert length(response["data"]) == 1
    end

    test "clamps limit to maximum of 500", %{conn: conn} do
      for _ <- 1..5 do
        media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})
      end

      conn = get(conn, "/api/media/recent_downloads?limit=9999")
      response = json_response(conn, 200)

      assert length(response["data"]) == 5
    end

    test "returns expected fields for each item", %{conn: conn} do
      media_item_fixture(%{media_downloaded_at: DateTime.utc_now()})

      conn = get(conn, "/api/media/recent_downloads")
      response = json_response(conn, 200)

      item = hd(response["data"])
      assert Map.has_key?(item, "id")
      assert Map.has_key?(item, "uuid")
      assert Map.has_key?(item, "title")
      assert Map.has_key?(item, "media_id")
      assert Map.has_key?(item, "source_id")
      assert Map.has_key?(item, "uploaded_at")
      assert Map.has_key?(item, "media_downloaded_at")
      assert Map.has_key?(item, "media_filepath")
      assert Map.has_key?(item, "thumbnail_filepath")
      assert Map.has_key?(item, "metadata_filepath")
      assert Map.has_key?(item, "nfo_filepath")
      assert Map.has_key?(item, "subtitle_filepaths")
    end

    test "returns empty data when no downloaded items exist", %{conn: conn} do
      _not_downloaded = media_item_fixture(%{media_downloaded_at: nil})

      conn = get(conn, "/api/media/recent_downloads")
      response = json_response(conn, 200)

      assert response["data"] == []
    end
  end
end
