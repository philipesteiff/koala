defmodule Koala.Release.Train.MessageFormatter.Slack do

  require Logger
  use Timex
  alias Koala.Release.Train.MessageFormatter

  @behaviour Koala.Release.Train.MessageFormatter

  @impl Koala.Release.Train.MessageFormatter
  def render() do

    schedules = MessageFormatter.schedules()
    team_list = MessageFormatter.team_list()

    label_upcoming = case MessageFormatter.label(schedules.upcoming) do
      {:has_label, label} -> label
      {:no_label} -> nil
    end

    label_next = case MessageFormatter.label(schedules.next) do
      {:has_label, label} -> label
      {:no_label} -> nil
    end

    "\n" <>
    "---------------------------------------------------------" <>
    "\n" <>
    format_release_title("Upcoming") <>
    "\n" <>
    "---------------------------------------------------------" <>
    "\n" <>
    "\n" <>
    "\n" <>
    build_header_message(label_upcoming, schedules.upcoming) <>
    "\n" <>
    "\n" <>
    build_content_list_message(label_upcoming, schedules.upcoming, team_list) <>
    "\n" <>
    "\n" <>
    "---------------------------------------------------------" <>
    "\n" <>
    format_release_title("Next") <>
    "\n" <>
    "---------------------------------------------------------" <>
    "\n" <>
    "\n" <>
    "\n" <>
    build_header_message(label_next, schedules.next) <>
    "\n" <>
    "\n" <>
    build_content_list_message(label_next, schedules.next, team_list) <>
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

           "-----------------------------" <>
           "\n" <>
           team_title <>
           "\n" <>
           "-----------------------------" <>
           "\n" <>

           (if(stories_blocked != "") do
              "------ :no_pedestrians: *Blocked Stories* ------" <>
              "\n" <>
              "\n" <>
              stories_blocked <>
              "\n" <>
              "\n"
            else
              ""
            end) <>

           (if(stories_not_completed != "") do
              "------ :building_construction: *In-Progress Stories* ------" <>
              "\n" <>
              "\n" <>
              stories_not_completed <>
              "\n" <>
              "\n"
            else
              ""
            end) <>

           (if(stories_completed != "") do
              "------ :white_check_mark:  *Completed Stories* ------" <>
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

  defp format_release_title(extra) do
    ":train2: *Release Train (#{extra})*"
  end

  defp format_release_version(release_tag_label) do
    company_name = Koala.Application.env(:clubhouse_company_name)
    label_id = release_tag_label["id"]
    version = release_tag_label["name"]
              |> String.replace_prefix(Koala.Application.env(:clubhouse_label_version_prefix), "")
    label_link = "<https://app.clubhouse.io/#{company_name}/label/#{label_id}|#{version}>"

    ":dart: *Release version: #{label_link}*"
  end

  defp format_release_departure_date(deployment_date) do
    ":bullettrain_side: *Departure date:* #{MessageFormatter.format_date(deployment_date)}"
  end

  defp format_release_code_freeze_date(code_freeze_date) do
    ":snowman: *Code freeze date:* #{
      MessageFormatter.format_date(code_freeze_date)
    }"
  end

  defp format_team_title(team) do
    "*#{team["name"]}* :gottarun:"
  end

  defp format_story_title(story) do
    ":package: *<#{story["app_url"]}|Story: #{story["name"]}>*"
  end

  defp format_story_due_date(story, belongs_to_release) do
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
  end

end