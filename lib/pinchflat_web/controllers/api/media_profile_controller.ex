defmodule PinchflatWeb.Api.MediaProfileController do
  use PinchflatWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema
  alias Pinchflat.Profiles
  alias PinchflatWeb.Schemas

  tags(["MediaProfiles"])

  operation(:index,
    operation_id: "Api.MediaProfileController.index",
    summary: "List media profiles",
    description: "Returns a list of all media profiles",
    responses: [
      ok: {"List of media profiles", "application/json", Schemas.MediaProfilesListResponse}
    ]
  )

  def index(conn, _params) do
    media_profiles = Profiles.list_media_profiles()

    conn
    |> put_status(:ok)
    |> json(%{data: media_profiles})
  end

  operation(:show,
    operation_id: "Api.MediaProfileController.show",
    summary: "Get media profile",
    description: "Returns details for a specific media profile",
    parameters: [
      id: [in: :path, description: "Media profile ID", schema: %Schema{type: :integer}, required: true]
    ],
    responses: [
      ok: {"Media profile details", "application/json", Schemas.MediaProfile},
      not_found: {"Media profile not found", "application/json", Schemas.NotFoundResponse}
    ]
  )

  def show(conn, %{"id" => id}) do
    media_profile = Profiles.get_media_profile!(id)

    conn
    |> put_status(:ok)
    |> json(media_profile)
  end

  operation(:create,
    operation_id: "Api.MediaProfileController.create",
    summary: "Create media profile",
    description: "Creates a new media profile",
    request_body: {"Media profile creation parameters", "application/json", Schemas.CreateMediaProfileRequest},
    responses: [
      created: {"Media profile created successfully", "application/json", Schemas.MediaProfile},
      unprocessable_entity: {"Validation error", "application/json", Schemas.ValidationErrorResponse}
    ]
  )

  def create(conn, %{"media_profile" => media_profile_params}) do
    case Profiles.create_media_profile(media_profile_params) do
      {:ok, media_profile} ->
        conn
        |> put_status(:created)
        |> json(media_profile)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  operation(:update,
    operation_id: "Api.MediaProfileController.update",
    summary: "Update media profile",
    description: "Updates an existing media profile",
    parameters: [
      id: [in: :path, description: "Media profile ID", schema: %Schema{type: :integer}, required: true]
    ],
    request_body: {"Media profile update parameters", "application/json", Schemas.UpdateMediaProfileRequest},
    responses: [
      ok: {"Media profile updated successfully", "application/json", Schemas.MediaProfile},
      not_found: {"Media profile not found", "application/json", Schemas.NotFoundResponse},
      unprocessable_entity: {"Validation error", "application/json", Schemas.ValidationErrorResponse}
    ]
  )

  def update(conn, %{"id" => id, "media_profile" => media_profile_params}) do
    media_profile = Profiles.get_media_profile!(id)

    case Profiles.update_media_profile(media_profile, media_profile_params) do
      {:ok, media_profile} ->
        conn
        |> put_status(:ok)
        |> json(media_profile)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  operation(:delete,
    operation_id: "Api.MediaProfileController.delete",
    summary: "Delete media profile",
    description: "Deletes a media profile and optionally its associated sources and media files",
    parameters: [
      id: [in: :path, description: "Media profile ID", schema: %Schema{type: :integer}, required: true],
      delete_files: [
        in: :query,
        description: "Also delete associated media files from disk",
        schema: %Schema{type: :boolean, default: false}
      ]
    ],
    responses: [
      ok: {"Media profile deletion started", "application/json", Schemas.ActionResponse},
      not_found: {"Media profile not found", "application/json", Schemas.NotFoundResponse}
    ]
  )

  def delete(conn, %{"id" => id} = params) do
    media_profile = Profiles.get_media_profile!(id)
    delete_files = params["delete_files"] == "true" || params["delete_files"] == true

    {:ok, _media_profile} = Profiles.delete_media_profile(media_profile, delete_files: delete_files)

    conn
    |> put_status(:ok)
    |> json(%{message: "Media profile deletion started"})
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%\{(\w+)\}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
