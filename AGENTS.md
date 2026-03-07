# Agent Guidelines for Pinchflat

Guidelines for AI agents working on this Elixir/Phoenix codebase.

## Project Overview

Pinchflat is a self-hosted media management app using:

- **Backend**: Elixir 1.17+, Phoenix 1.7, Ecto with SQLite
- **Frontend**: Phoenix LiveView, Tailwind CSS, esbuild
- **Background Jobs**: Oban
- **Testing**: ExUnit with Mox for mocking

## Build/Lint/Test Commands

**Always use Docker for development and testing.** The project has permission issues when mixing Docker and local builds.

**Database backup:** Use `pinchflat.db.backup-*` files for testing and development with real data. These contain production-like data for debugging issues.

```bash
# Run all checks (compile, format, credo, tests, sobelow, prettier)
docker compose run --rm phx mix check

# Run tests only
docker compose run --rm phx mix test

# Run a single test file
docker compose run --rm phx mix test test/pinchflat/media_test.exs

# Run a specific test by line number
docker compose run --rm phx mix test test/pinchflat/media_test.exs:42

# Run tests matching a pattern
docker compose run --rm phx mix test --only describe:"list_media_items"

# Format Elixir code
docker compose run --rm phx mix format

# Run Credo linter
docker compose run --rm phx mix credo

# Security analysis
docker compose run --rm phx mix sobelow --config

# Format JS/CSS/YAML/JSON
docker compose run --rm phx yarn run lint:fix

# Start the development server
docker compose up
```

## Code Style Guidelines

### Module Structure

Follow this order in modules:

1. `@moduledoc` - required for all public modules
2. `use`/`import`/`alias`/`require` statements
3. Module attributes (`@allowed_fields`, `@impl`, etc.)
4. Public functions with `@doc`
5. Private functions

```elixir
defmodule Pinchflat.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  use Pinchflat.Media.MediaQuery

  alias Pinchflat.Repo
  alias Pinchflat.Media.MediaItem

  @doc """
  Returns the list of media_items.
  """
  def list_media_items do
    Repo.all(MediaItem)
  end

  defp some_private_function do
    # ...
  end
end
```

### Imports and Aliases

- Use `alias` for frequently used modules
- Prefer explicit imports: `import Ecto.Query, warn: false`
- Group aliases alphabetically
- Use `alias __MODULE__` for self-reference in schemas

### Naming Conventions

- **Modules**: PascalCase matching file path (`Pinchflat.Media.MediaItem`)
- **Functions**: snake*case with verb prefixes (`get*`, `list*`, `create*`, `update*`, `delete*`)
- **Predicate functions**: end with `?` (`pending_download?/1`)
- **Private functions**: prefix with `do_` for wrapper pattern (`do_delete_media_files`)
- **Workers**: suffix with `Worker` (`MediaDownloadWorker`)
- **Fixtures**: suffix with `_fixture` (`media_item_fixture`)

### Formatting

- Line length: 120 characters max
- Use `mix format` - config in `.formatter.exs`
- Prettier for JS/CSS/YAML/JSON

### Return Types

Document returns in `@doc`:

```elixir
@doc """
Creates a media_item.

Returns {:ok, %MediaItem{}} | {:error, %Ecto.Changeset{}}
"""
def create_media_item(attrs) do
  # ...
end
```

### Error Handling

- Use `{:ok, result}` / `{:error, reason}` tuples
- Use `!` suffix for functions that raise (`get_media_item!/1`)
- Pattern match on error tuples explicitly
- Rescue specific exceptions when needed:

```elixir
def perform(%Oban.Job{args: %{"id" => id}}) do
  # ...
rescue
  Ecto.NoResultsError -> Logger.info("Record not found")
  Ecto.StaleEntryError -> Logger.info("Record stale")
end
```

### Oban Workers

```elixir
defmodule Pinchflat.Downloading.MediaDownloadWorker do
  @moduledoc false

  use Oban.Worker,
    queue: :media_fetching,
    priority: 5,
    unique: [period: :infinity, states: [:available, :scheduled, :retryable, :executing]],
    tags: ["media_item", "show_in_dashboard"]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = args}) do
    # Return :ok, {:ok, result}, {:error, reason}, or {:snooze, seconds}
  end
end
```

### Testing Patterns

Use `Pinchflat.DataCase` for database tests:

```elixir
defmodule Pinchflat.MediaTest do
  use Pinchflat.DataCase

  import Pinchflat.MediaFixtures
  import Pinchflat.SourcesFixtures

  alias Pinchflat.Media

  describe "list_media_items/0" do
    test "returns all media_items" do
      media_item = media_item_fixture()
      assert Media.list_media_items() == [media_item]
    end
  end
end
```

### Mocking with Mox

Mocks are defined in `test/test_helper.exs`:

- `YtDlpRunnerMock` - yt-dlp commands
- `HTTPClientMock` - HTTP requests
- `UserScriptRunnerMock` - user scripts
- `AppriseRunnerMock` - notifications

```elixir
test "calls user script" do
  expect(UserScriptRunnerMock, :run, fn :media_deleted, data ->
    assert data.id == media_item.id
    {:ok, "", 0}
  end)

  Media.delete_media_item(media_item, delete_files: true)
end
```

### Test Fixtures

Create fixtures in `test/support/fixtures/`:

```elixir
def media_item_fixture(attrs \\ %{}) do
  {:ok, media_item} =
    attrs
    |> Enum.into(%{
      media_id: Faker.String.base64(12),
      title: Faker.Commerce.product_name(),
      source_id: source_fixture().id
    })
    |> Pinchflat.Media.create_media_item()

  media_item
end
```

### Test Helpers

From `Pinchflat.TestingHelperMethods`:

- `now/0` - current UTC datetime
- `now_minus/2` - datetime in past (`now_minus(5, :days)`)
- `now_plus/2` - datetime in future
- `assert_changed/2` - verify state change

## Project Structure

```
lib/
  pinchflat/           # Business logic contexts
    media/             # Media context (MediaItem, queries)
    sources/           # Source context
    downloading/       # Download workers and helpers
    yt_dlp/            # yt-dlp integration
  pinchflat_web/       # Phoenix web layer
test/
  pinchflat/           # Context tests
  pinchflat_web/       # Controller/LiveView tests
  support/
    fixtures/          # Test data factories
    data_case.ex       # Database test setup
    conn_case.ex       # HTTP test setup
```

## Pre-commit Hooks

Lefthook runs on commit (configured in `lefthook.yml`):

- `prettier` - JS/CSS/YAML/JSON formatting (runs in Docker)
- `mix format` - Elixir formatting (runs in Docker)
- `typos` - spell checking (runs on host)
- `actionlint` - GitHub Actions validation (runs on host)

**Note:** `prettier` and `mix format` run inside Docker to avoid permission issues. `typos` and `actionlint` run on the host machine.

Bypass if needed: `git commit --no-verify -m "message"`
