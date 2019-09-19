defmodule Clubhouse.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.clubhouse.io/api/v2"
  plug Tesla.Middleware.JSON

  def search_stories_by_label(label_name) do
    get(
      "/search/stories?" <> "token=#{token()}",
      query: [
        query: "label:#{label_name}"
      ]
    )
  end

  def create_label(label_name) do
    post(
      "/labels?" <> "token=#{token()}",
      %{
        color: Koala.Application.env(:clubhouse_label_color),
        name: label_name
      }
    )
  end

  def get_label_list() do
    get("/labels?" <> "token=#{token()}")
  end

  def get_epic_list() do
    get("/epics?" <> "token=#{token()}")
  end

  def get_project_list() do
    get("/projects?" <> "token=#{token()}")
  end

  defp token() do
    Koala.Application.env(:clubhouse_token)
  end

end
