defmodule Koala.Release.Train.MessageFormatter do

  require Logger
  use Timex

  @callback render() :: String.t

  def schedules() do
    Koala.Release.Train.Calendar.get_schedules()
  end

  def team_list() do
    Koala.Release.Train.Team.List.get()
  end

  def label(event) do
    label = Koala.Release.Train.Label.Get.get_label_by_version(event.version.name)
    if (label != nil) do
      {:has_label, label}
    else
      {:no_label}
    end
  end

  def stories_group_by_team(label) do
    Koala.Clubhouse.Story.Search.get_stories_by_label(label["name"])
    |> Enum.group_by(fn story -> story["project_id"] end)
  end

  def find_team(team_list, project_id) do
    team_list
    |> Enum.find(
         nil,
         fn team -> project_id == team["id"] end
       )
  end


  def belongs_to_current_release(story, event) do
    date = story["deadline"]
    deadline_date = event.code_freeze_event.date
    date != nil && parse_date(date)
                   |> Timex.before?(deadline_date)
  end

  def stories_completed(stories, story_reducer) do
    stories
    |> Enum.filter(fn story -> story["completed"] && !story["blocked"] end)
    |> Enum.reduce("", story_reducer)
  end

  def stories_not_completed(stories, story_reducer) do
    stories
    |> Enum.filter(fn story -> !story["completed"] && !story["blocked"] end)
    |> Enum.reduce("", story_reducer)
  end

  def stories_blocked(stories, story_reducer) do
    stories
    |> Enum.filter(fn story -> !story["completed"] && story["blocked"] end)
    |> Enum.reduce("", story_reducer)
  end

  def format_date(date) do
    simple_date = Timex.format!(date, "%m/%d/%Y", :strftime)
    relative_date = date
                    |> Timex.format("{relative}", :relative)
                    |> elem(1)
    "#{simple_date} (#{relative_date})"
  end

  def parse_date(raw_date),
      do: Timex.parse(raw_date, "{ISO:Extended}")
          |> elem(1)


end