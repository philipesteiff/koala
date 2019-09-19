defmodule Gitlab.Api do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "#{Koala.Application.env(:gitlab_base_url)}/api/v4"
  plug Tesla.Middleware.Headers, [{"PRIVATE-TOKEN", token()}]
  plug Tesla.Middleware.JSON

  @project_encoded URI.encode(Koala.Application.env(:gitlab_project_path), &URI.char_unreserved?/1)

  def create_milestone(title, description, due_date) do
    post(
      "/projects/#{@project_encoded}/milestones",
      %{
        title: title,
        description: description,
        due_date: due_date
      }
    )
  end

  def edit_milestone(milestone_id, title, description, due_date, true) do
    edit_milestone(milestone_id, title, description, due_date, "activate")
  end

  def edit_milestone(milestone_id, title, description, due_date, false) do
    edit_milestone(milestone_id, title, description, due_date, "close")
  end

  def edit_milestone(milestone_id, title, description, due_date, state_event) do
    put(
      "/projects/#{@project_encoded}/milestones/#{milestone_id}",
      %{
        title: title,
        description: description,
        due_date: due_date,
        state_event: state_event
      }
    )
  end

  def get_all_active_milestones() do
    get(
      "/projects/#{@project_encoded}/milestones",
      query: [
        state: "active"
      ]
    )
  end

  def get_all_milestones() do
    get(
      "/projects/#{@project_encoded}/milestones"
    )
  end

  def search_milestone_by_title(query, true) do
    search_milestone_by_title(query, "active")
  end

  def search_milestone_by_title(query, false) do
    search_milestone_by_title(query, "closed")
  end

  def search_milestone_by_title(query, is_active) do
    get(
      "/projects/#{@project_encoded}/milestones",
      query: [
        title: query,
        state: is_active
      ]
    )
  end

  defp token() do
    Koala.Application.env(:gitlab_token)
  end

end
