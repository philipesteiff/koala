defmodule Koala.Release.Train.MessageFormatter.Gitlab do

  require Logger
  use Timex
  alias Koala.Release.Train.MessageFormatter

  @behaviour Koala.Release.Train.MessageFormatter

  @impl Koala.Release.Train.MessageFormatter
  def render() do

    schedules = MessageFormatter.schedules()
    team_list = MessageFormatter.team_list()

    label = case MessageFormatter.label(schedules.upcoming) do
      {:has_label, label} -> label
      {:no_label} -> nil
    end

    "\n" <>
    format_release_title() <>
    "\n" <>
    "\n" <>
    "\n" <>
    build_header_message(label, schedules.upcoming) <>
    "\n" <>
    "\n" <>
    build_content_list_message(label, schedules.next, team_list) <>
    "\n" <>
    "\n"
  end

  def build_header_message(label, event) do
    if label != nil do
      format_release_version(label) <>
      "\n" <>
      format_release_code_freeze_date(event.code_freeze_event.date) <>
      "\n" <>
      format_release_departure_date(event.release_event.date) <>
      "\n" <>
      "\n"
    else
      "No version found!"
    end
  end

  def build_content_list_message(label, event, team_list) do
    MessageFormatter.stories_group_by_team(label)
    |> Enum.map(
         fn {project_id, stories} ->

           team_title = MessageFormatter.find_team(team_list, project_id)
                        |> format_team_title()

           story_reducer = fn story, acc -> build_story(story, event) <> "#{acc}" end

           stories_completed = MessageFormatter.stories_completed(stories, story_reducer)

           stories_not_completed = MessageFormatter.stories_not_completed(stories, story_reducer)

           stories_blocked = MessageFormatter.stories_blocked(stories, story_reducer)

           "\n" <>
           team_title <>
           "======" <>
           "\n" <>
           "\n" <>

           (if(stories_blocked != "") do
              "### :no_pedestrians: *Blocked Stories*" <>
              "\n" <>
              "\n" <>
              stories_blocked <>
              "\n" <>
              "\n"
            else
              ""
            end) <>

           (if(stories_not_completed != "") do
              "### :building_construction: *In-Progress Stories*" <>
              "\n" <>
              "\n" <>
              stories_not_completed <>
              "\n" <>
              "\n"
            else
              ""
            end) <>

           (if(stories_completed != "") do
              "### :white_check_mark:  *Completed Stories*" <>
              "\n" <>
              "\n" <>
              stories_completed <>
              "\n" <>
              "\n"
            else
              ""
            end)
         end
       )
    |> Enum.join()
  end

  defp build_story(story, event) do
    format_story_title(story) <>
    "\n" <>
    format_story_due_date(
      story,
      MessageFormatter.belongs_to_current_release(story, event)
    ) <>
    "\n" <>
    "\n"
  end

  def format_release_title() do
    "# :train2: *Release Train*"
  end

  def format_release_version(release_tag_label) do
    company_name = Koala.Application.env(:clubhouse_company_name)
    label_id = release_tag_label["id"]
    version = release_tag_label["name"]
              |> String.replace_prefix(Koala.Application.env(:clubhouse_label_version_prefix), "")

    ":dart: *Release version: [#{version}](https://app.clubhouse.io/#{company_name}/label/#{label_id})*" <>
    "\n"
  end

  def format_release_departure_date(deployment_date) do
    ":bullettrain_side: *Departure date:* #{MessageFormatter.format_date(deployment_date)}"
    <>
    "\n"
  end

  def format_release_code_freeze_date(code_freeze_date) do
    ":snowman: *Code freeze date:* #{
      MessageFormatter.format_date(code_freeze_date)
    }"
    <>
    "\n"
  end

  def format_team_title(team) do
    "*#{team["name"]}*" <>
    "\n"
  end

  def format_story_title(story) do
    ":package: *[Story: #{story["name"]}](#{story["app_url"]})*"
    <>
    "\n"
  end

  def format_story_due_date(story, belongs_to_release) do
    ":calendar: Due date: #{
      if story["deadline"] != nil do
        deadline_date = MessageFormatter.parse_date(story["deadline"])
                        |> MessageFormatter.format_date()
        deadline_date <>
        (if !belongs_to_release do
           " :alert: Due date doesn't fit in the code-freeze date :alert:"
         else
           ""
         end)
      else
        "No date :warning:"
      end
    }"
    <>
    "\n"
  end

  def format_story_next_release_title() do
    ":station:  *Next Trains*"
  end

  def format_milestone_title(event_id, version) do
    "[#{event_id}] App-version: #{version}"
  end

  def format_log_section() do
    "## Log \n\n| Entry | Date | \n| ------------- |:-------------:| \n"
  end

  def format_log_entry(log) do
    if(log != nil) do
      "| " <> log <> "|" <> " #{Timex.now("Europe/Madrid")}" <> "| \n"
    else
      ""
    end
  end

end