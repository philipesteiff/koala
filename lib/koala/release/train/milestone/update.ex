defmodule Koala.Release.Train.Milestone.Update do

  require Logger

  alias Koala.Release.Train.MessageFormatter.Gitlab, as: GitlabFormatter

  def update() do
    Koala.Slack.Message.Send.send_message("Updating Milestone... (triggered via cron)")
    update(nil, nil)
  end

  def update(query, log) do
    schedules = Koala.Release.Train.Calendar.get_schedules()
    event_id = schedules.upcoming.id
    version = schedules.upcoming.version.name

    match = if query == nil do
      event_id
    else
      query
    end

    case Koala.Release.Train.Milestone.Get.get_all_active() do
      {:ok, milestones} ->
        train_status_content = Koala.Release.Train.Status.Render.get_train_report(:gitlab)

        milestone = Gitlab.Helper.find_milestone(milestones, match)

        case milestone do
          nil -> Koala.Release.Train.Milestone.Create.create(event_id, version, train_status_content)
          milestone -> update_milestone(milestone, event_id, version, train_status_content, log)
        end
      {:error, message} -> Koala.Slack.Message.Send.send_message(message)
    end

  end

  def update_milestone(milestone, event_id, version, train_status_content, log) do

    description = milestone["description"]
    new_title = GitlabFormatter.format_milestone_title(event_id, version)
    log_section = GitlabFormatter.format_log_section()

    new_description = case String.split(description, log_section, parts: 2) do
      [_, left] ->
        train_status_content <> log_section <> left <> GitlabFormatter.format_log_entry(log)
      [_] -> train_status_content <> log_section <> GitlabFormatter.format_log_entry(log)
    end

    case Gitlab.Api.edit_milestone(milestone["id"], new_title, new_description, nil, true) do
      {:ok, _} -> {:ok, Gitlab.Helper.get_milestone_url(milestone["iid"])}
      {:error, _} -> {:error, "Failed to update the milestone with id #{milestone["id"]}"}
    end
  end

end
