defmodule Koala.Release.Train.Milestone.Create do

  require Logger

  def create(event_id, version, train_status_content) do
    title = "[#{event_id}] App-version: #{version}"
    description = train_status_content

    case Gitlab.Api.create_milestone(title, description, nil) do
      {:ok, result} -> {:ok, result.body}
      {:error, _} -> {:error, "Failed to search milestone with id: #{event_id}."}
    end
  end

end
