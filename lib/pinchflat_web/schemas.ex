defmodule PinchflatWeb.Schemas do
  @moduledoc """
  OpenAPI schemas for the Pinchflat API.
  """

  alias OpenApiSpex.Schema

  defmodule HealthResponse do
    @moduledoc """
    Schema for health check response.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "HealthResponse",
      description: "Health check response",
      type: :object,
      properties: %{
        status: %Schema{type: :string, description: "Health status", example: "ok"}
      },
      required: [:status]
    })
  end

  defmodule MediaProfile do
    @moduledoc """
    Schema for a media profile.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MediaProfile",
      description: "Configuration profile for media downloads",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Internal database ID", example: 1},
        name: %Schema{type: :string, description: "Profile name", example: "HD Videos"},
        output_path_template: %Schema{
          type: :string,
          description: "Template for output file paths",
          example: "/{{ source_custom_name }}/{{ upload_yyyy_mm_dd }} {{ title }}/{{ title }} [{{ id }}].{{ ext }}"
        },
        download_subs: %Schema{type: :boolean, description: "Download subtitles", example: false},
        download_auto_subs: %Schema{type: :boolean, description: "Download auto-generated subtitles", example: false},
        embed_subs: %Schema{type: :boolean, description: "Embed subtitles into media file", example: false},
        sub_langs: %Schema{type: :string, description: "Subtitle languages", example: "en"},
        download_thumbnail: %Schema{type: :boolean, description: "Download thumbnail", example: true},
        embed_thumbnail: %Schema{type: :boolean, description: "Embed thumbnail into media file", example: true},
        download_source_images: %Schema{type: :boolean, description: "Download source images", example: false},
        download_metadata: %Schema{type: :boolean, description: "Download metadata", example: true},
        embed_metadata: %Schema{type: :boolean, description: "Embed metadata into media file", example: true},
        download_nfo: %Schema{type: :boolean, description: "Download NFO file", example: false},
        sponsorblock_behaviour: %Schema{
          type: :string,
          enum: [:disabled, :mark, :remove],
          description: "SponsorBlock behavior",
          example: :disabled
        },
        sponsorblock_categories: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "SponsorBlock categories",
          example: ["sponsor", "intro"]
        },
        shorts_behaviour: %Schema{
          type: :string,
          enum: [:include, :exclude, :only],
          description: "Shorts handling behavior",
          example: :include
        },
        livestream_behaviour: %Schema{
          type: :string,
          enum: [:include, :exclude, :only],
          description: "Livestream handling behavior",
          example: :include
        },
        audio_track: %Schema{type: :string, description: "Preferred audio track", example: nil},
        preferred_resolution: %Schema{
          type: :string,
          enum: [:"4320p", :"2160p", :"1440p", :"1080p", :"720p", :"480p", :"360p", :audio],
          description: "Preferred video resolution",
          example: :"1080p"
        },
        media_container: %Schema{type: :string, description: "Media container format", example: "mp4"},
        redownload_delay_days: %Schema{type: :integer, description: "Delay before redownloading", example: nil},
        inserted_at: %Schema{type: :string, format: :date_time, description: "Creation timestamp"},
        updated_at: %Schema{type: :string, format: :date_time, description: "Last update timestamp"}
      },
      required: [:id, :name, :output_path_template]
    })
  end

  defmodule Source do
    @moduledoc """
    Schema for a source (channel or playlist).
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Source",
      description: "A media source (YouTube channel or playlist)",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Internal database ID", example: 1},
        uuid: %Schema{
          type: :string,
          format: :uuid,
          description: "Public unique identifier",
          example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        },
        enabled: %Schema{type: :boolean, description: "Whether the source is active", example: true},
        custom_name: %Schema{type: :string, description: "Display name for the source", example: "My Channel"},
        description: %Schema{type: :string, description: "Source description", example: "A collection of videos"},
        collection_name: %Schema{
          type: :string,
          description: "Original collection name",
          example: "Original Channel Name"
        },
        collection_id: %Schema{type: :string, description: "External collection ID", example: "UCxxxxxxxxxxxxxxxxxxx"},
        collection_type: %Schema{
          type: :string,
          enum: [:channel, :playlist],
          description: "Type of collection",
          example: :channel
        },
        original_url: %Schema{
          type: :string,
          description: "Original source URL",
          example: "https://www.youtube.com/channel/UCxxx"
        },
        index_frequency_minutes: %Schema{type: :integer, description: "Indexing frequency in minutes", example: 1440},
        fast_index: %Schema{type: :boolean, description: "Use fast indexing", example: false},
        download_media: %Schema{type: :boolean, description: "Download media items", example: true},
        last_indexed_at: %Schema{type: :string, format: :date_time, description: "Last indexing timestamp"},
        download_cutoff_date: %Schema{type: :string, format: :date, description: "Only download media after this date"},
        retention_period_days: %Schema{type: :integer, description: "Delete media older than this many days"},
        title_filter_regex: %Schema{type: :string, description: "Regex to filter media titles"},
        min_duration_seconds: %Schema{type: :integer, description: "Minimum media duration"},
        max_duration_seconds: %Schema{type: :integer, description: "Maximum media duration"},
        series_directory: %Schema{type: :string, description: "Directory for series organization"},
        nfo_filepath: %Schema{type: :string, description: "Path to NFO file"},
        poster_filepath: %Schema{type: :string, description: "Path to poster image"},
        fanart_filepath: %Schema{type: :string, description: "Path to fanart image"},
        banner_filepath: %Schema{type: :string, description: "Path to banner image"},
        media_profile_id: %Schema{type: :integer, description: "ID of associated media profile"},
        media_profile: %Schema{
          allOf: [MediaProfile],
          description: "Associated media profile"
        },
        inserted_at: %Schema{type: :string, format: :date_time, description: "Creation timestamp"},
        updated_at: %Schema{type: :string, format: :date_time, description: "Last update timestamp"}
      },
      required: [:id, :uuid, :custom_name, :collection_name, :collection_id, :collection_type]
    })
  end

  defmodule MediaItem do
    @moduledoc """
    Schema for a media item.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MediaItem",
      description: "A media item that has been downloaded",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Internal database ID", example: 1},
        uuid: %Schema{
          type: :string,
          format: :uuid,
          description: "Unique identifier",
          example: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        },
        title: %Schema{type: :string, description: "Media title", example: "My Video Title"},
        media_id: %Schema{type: :string, description: "External media ID", example: "youtube_video_id"},
        source_id: %Schema{type: :integer, description: "ID of the source this media belongs to", example: 1},
        source: %Schema{
          allOf: [Source],
          description: "The source this media belongs to"
        },
        uploaded_at: %Schema{
          type: :string,
          format: :date_time,
          description: "When the media was originally uploaded",
          example: "2024-01-01T12:00:00Z"
        },
        media_downloaded_at: %Schema{
          type: :string,
          format: :date_time,
          description: "When the media was downloaded",
          example: "2024-01-02T10:30:00Z"
        },
        media_filepath: %Schema{
          type: :string,
          description: "Path to the downloaded media file",
          example: "/downloads/video.mp4"
        },
        thumbnail_filepath: %Schema{
          type: :string,
          description: "Path to the thumbnail file",
          example: "/downloads/thumbnail.jpg"
        },
        metadata_filepath: %Schema{
          type: :string,
          description: "Path to the metadata file",
          example: "/downloads/metadata.json"
        },
        nfo_filepath: %Schema{
          type: :string,
          description: "Path to the NFO file",
          example: "/downloads/video.nfo"
        },
        subtitle_filepaths: %Schema{
          type: :array,
          items: %Schema{type: :string},
          description: "Paths to subtitle files",
          example: ["/downloads/subtitle_en.srt", "/downloads/subtitle_de.srt"]
        },
        inserted_at: %Schema{type: :string, format: :date_time, description: "Creation timestamp"},
        updated_at: %Schema{type: :string, format: :date_time, description: "Last update timestamp"}
      },
      required: [:id, :uuid, :title, :media_id, :source_id]
    })
  end

  defmodule RecentDownloadsResponse do
    @moduledoc """
    Schema for recent downloads response.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RecentDownloadsResponse",
      description: "Response containing a list of recently downloaded media items",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: MediaItem,
          description: "List of recently downloaded media items"
        }
      },
      required: [:data]
    })
  end

  defmodule SourcesListResponse do
    @moduledoc """
    Schema for listing sources response.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "SourcesListResponse",
      description: "Response containing a list of sources",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: Source,
          description: "List of sources"
        }
      },
      required: [:data]
    })
  end

  defmodule CreateSourceRequest do
    @moduledoc """
    Schema for creating a new source.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CreateSourceRequest",
      description: "Request body for creating a new source",
      type: :object,
      properties: %{
        source: %Schema{
          type: :object,
          properties: %{
            original_url: %Schema{
              type: :string,
              description: "YouTube channel or playlist URL (required for creation)",
              example: "https://www.youtube.com/channel/UCxxx"
            },
            media_profile_id: %Schema{
              type: :integer,
              description: "Media profile ID (required for creation)",
              example: 1
            },
            custom_name: %Schema{
              type: :string,
              description: "Custom display name (optional, defaults to collection name)"
            },
            description: %Schema{type: :string, description: "Source description"},
            enabled: %Schema{type: :boolean, description: "Whether the source is active", default: true},
            download_media: %Schema{type: :boolean, description: "Download media items", default: true},
            fast_index: %Schema{type: :boolean, description: "Use fast indexing", default: false},
            index_frequency_minutes: %Schema{
              type: :integer,
              description: "Indexing frequency in minutes",
              default: 1440
            },
            download_cutoff_date: %Schema{
              type: :string,
              format: :date,
              description: "Only download media after this date (YYYY-MM-DD)"
            },
            retention_period_days: %Schema{
              type: :integer,
              description: "Delete media older than this many days"
            },
            title_filter_regex: %Schema{type: :string, description: "Regex to filter media titles"},
            min_duration_seconds: %Schema{type: :integer, description: "Minimum media duration in seconds"},
            max_duration_seconds: %Schema{type: :integer, description: "Maximum media duration in seconds"},
            output_path_template_override: %Schema{
              type: :string,
              description: "Override the media profile's output path template"
            }
          },
          required: [:original_url, :media_profile_id]
        }
      },
      required: [:source]
    })
  end

  defmodule UpdateSourceRequest do
    @moduledoc """
    Schema for updating an existing source.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UpdateSourceRequest",
      description: "Request body for updating a source",
      type: :object,
      properties: %{
        source: %Schema{
          type: :object,
          properties: %{
            custom_name: %Schema{type: :string, description: "Custom display name"},
            description: %Schema{type: :string, description: "Source description"},
            enabled: %Schema{type: :boolean, description: "Whether the source is active"},
            download_media: %Schema{type: :boolean, description: "Download media items"},
            fast_index: %Schema{type: :boolean, description: "Use fast indexing"},
            index_frequency_minutes: %Schema{type: :integer, description: "Indexing frequency in minutes"},
            download_cutoff_date: %Schema{
              type: :string,
              format: :date,
              description: "Only download media after this date"
            },
            retention_period_days: %Schema{type: :integer, description: "Delete media older than this many days"},
            title_filter_regex: %Schema{type: :string, description: "Regex to filter media titles"},
            min_duration_seconds: %Schema{type: :integer, description: "Minimum media duration in seconds"},
            max_duration_seconds: %Schema{type: :integer, description: "Maximum media duration in seconds"},
            output_path_template_override: %Schema{
              type: :string,
              description: "Override the media profile's output path template"
            },
            media_profile_id: %Schema{type: :integer, description: "Media profile ID"}
          }
        }
      },
      required: [:source]
    })
  end
end
