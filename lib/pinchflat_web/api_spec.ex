defmodule PinchflatWeb.ApiSpec do
  @moduledoc """
  OpenAPI 3.0 specification for the Pinchflat API.
  """

  alias OpenApiSpex.{Info, MediaType, OpenApi, Parameter, PathItem, Response, Server}

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
      paths: %{
        "/healthcheck" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "HealthController.check",
            summary: "Health check",
            description: "Returns the health status of the application",
            tags: ["System"],
            responses: %{
              "200" => %Response{
                description: "Success",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.HealthResponse
                  }
                }
              }
            }
          }
        },
        "/api/spec" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "ApiSpecController.spec",
            summary: "OpenAPI specification",
            description: "Returns the OpenAPI 3.0 specification document for this API",
            tags: ["System"],
            responses: %{
              "200" => %Response{
                description: "OpenAPI specification JSON",
                content: %{
                  "application/json" => %MediaType{
                    schema: %OpenApiSpex.Schema{
                      type: :object,
                      description: "OpenAPI 3.0 specification"
                    }
                  }
                }
              }
            }
          }
        },
        "/api/media/recent_downloads" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Api.MediaController.recent_downloads",
            summary: "Recent downloads",
            description: "Returns a list of recently downloaded media items",
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :limit,
                in: :query,
                description: "Maximum number of results to return (1-500)",
                schema: %OpenApiSpex.Schema{type: :integer, minimum: 1, maximum: 500, default: 50}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Success",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.RecentDownloadsResponse
                  }
                }
              }
            }
          }
        },
        "/sources" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.index",
            summary: "List sources",
            description: "Returns a list of all sources",
            tags: ["Sources"],
            responses: %{
              "200" => %Response{
                description: "List of sources",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.SourcesListResponse
                  }
                }
              }
            }
          },
          post: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.create",
            summary: "Create source",
            description: "Creates a new source from a YouTube channel or playlist URL",
            tags: ["Sources"],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Source creation parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.CreateSourceRequest
                }
              }
            },
            responses: %{
              "201" => %Response{
                description: "Source created successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          }
        },
        "/sources/{id}" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.show",
            summary: "Get source",
            description: "Returns details for a specific source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Source details",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          },
          put: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.update",
            summary: "Update source",
            description: "Updates an existing source",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              }
            ],
            requestBody: %OpenApiSpex.RequestBody{
              description: "Source update parameters",
              required: true,
              content: %{
                "application/json" => %MediaType{
                  schema: PinchflatWeb.Schemas.UpdateSourceRequest
                }
              }
            },
            responses: %{
              "200" => %Response{
                description: "Source updated successfully",
                content: %{
                  "application/json" => %MediaType{
                    schema: PinchflatWeb.Schemas.Source
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              },
              "422" => %Response{
                description: "Validation error"
              }
            }
          },
          delete: %OpenApiSpex.Operation{
            operationId: "Sources.SourceController.delete",
            summary: "Delete source",
            description: "Deletes a source and optionally its associated media files",
            tags: ["Sources"],
            parameters: [
              %Parameter{
                name: :id,
                in: :path,
                required: true,
                description: "Source ID",
                schema: %OpenApiSpex.Schema{type: :integer}
              },
              %Parameter{
                name: :delete_files,
                in: :query,
                description: "Also delete associated media files from disk",
                schema: %OpenApiSpex.Schema{type: :boolean, default: false}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Source deletion started",
                content: %{
                  "application/json" => %MediaType{
                    schema: %OpenApiSpex.Schema{
                      type: :object,
                      properties: %{
                        message: %OpenApiSpex.Schema{type: :string}
                      }
                    }
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/sources/opml" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.opml_feed",
            summary: "OPML feed",
            description:
              "Returns an OPML feed containing all sources as podcast feeds. Useful for importing into podcast clients.",
            tags: ["Podcasts"],
            responses: %{
              "200" => %Response{
                description: "OPML XML feed",
                content: %{
                  "application/opml+xml" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, description: "OPML XML document"}
                  }
                }
              }
            }
          }
        },
        "/sources/{uuid}/feed" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.rss_feed",
            summary: "RSS feed for source",
            description:
              "Returns an RSS podcast feed for a specific source. Contains up to 2000 most recent media items.",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Source UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "RSS XML feed",
                content: %{
                  "application/rss+xml" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, description: "RSS XML document"}
                  }
                }
              },
              "404" => %Response{
                description: "Source not found"
              }
            }
          }
        },
        "/sources/{uuid}/feed_image" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.feed_image",
            summary: "Source feed image",
            description: "Returns the cover image for a source's podcast feed",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Source UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Image file",
                content: %{
                  "image/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Image file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Image not found"
              }
            }
          }
        },
        "/media/{uuid}/episode_image" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "Podcasts.PodcastController.episode_image",
            summary: "Episode thumbnail",
            description: "Returns the thumbnail image for a specific media item",
            tags: ["Podcasts"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Media item UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Image file",
                content: %{
                  "image/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Image file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Image not found"
              }
            }
          }
        },
        "/media/{uuid}/stream" => %PathItem{
          get: %OpenApiSpex.Operation{
            operationId: "MediaItems.MediaItemController.stream",
            summary: "Stream media file",
            description: """
            Streams a media file with HTTP Range request support for seeking.
            Supports partial content delivery (206) for efficient streaming.
            """,
            tags: ["Media"],
            parameters: [
              %Parameter{
                name: :uuid,
                in: :path,
                required: true,
                description: "Media item UUID",
                schema: %OpenApiSpex.Schema{type: :string, format: :uuid}
              },
              %Parameter{
                name: :range,
                in: :header,
                description: "Byte range for partial content (e.g., 'bytes=0-1023')",
                schema: %OpenApiSpex.Schema{type: :string, example: "bytes=0-1023"}
              }
            ],
            responses: %{
              "200" => %Response{
                description: "Full media file",
                content: %{
                  "video/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Media file data"}
                  },
                  "audio/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Media file data"}
                  }
                }
              },
              "206" => %Response{
                description: "Partial content (for range requests)",
                content: %{
                  "video/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Partial media file data"}
                  },
                  "audio/*" => %MediaType{
                    schema: %OpenApiSpex.Schema{type: :string, format: :binary, description: "Partial media file data"}
                  }
                }
              },
              "404" => %Response{
                description: "Media file not found"
              }
            }
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
