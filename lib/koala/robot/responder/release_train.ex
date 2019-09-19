defmodule Koala.Robot.Responder.ReleaseTrain do

  use Hedwig.Responder
  require Logger

  @usage """
  #{Koala.Application.env(:bot_name)} info - Replies with a full release train status.
  """
  respond ~r/info(!)?/i, msg do
    reply msg, Koala.Release.Train.Status.Render.get_train_report(:slack)
  end

  @usage """
  #{
    Koala.Application.env(:bot_name)
  } log <x.x.x> <log text message> - Add an log entry in a specific milestone fetched by version.
  """
  respond ~r/log (\d+.\d+.\d+)\s?(.+)/, msg do

    version = msg.matches[1]
    log = msg.matches[2]

    response = case Koala.Release.Train.Milestone.Update.update(version, log) do
      {:ok, milestone_url} -> "Milestone updated: <#{milestone_url}|link>"
      {:error, error_message} -> error_message
    end

    reply msg, response
  end

  @usage """
  #{
    Koala.Application.env(:bot_name)
  } history <x.x.x> - Search the document(milestone) by version.
  """
  respond ~r/history (\d+.\d+.\d+)?/i, msg do
    version = msg.matches[1]

    response = case Koala.Release.Train.Milestone.Get.get_all() do
      {:ok, milestones} ->
        milestone = Gitlab.Helper.find_milestone(milestones, version)
        id = milestone["iid"]

        if id == nil do
          "Milestone with version #{version} not found"
        else
          "Found <#{
            Gitlab.Helper.get_milestone_url(milestone["iid"])
          }|Milestone v#{version}>"
        end
      {:error, error_message} -> error_message
    end

    reply msg, response
  end

  # Temp solution to show helper section when nothing else matches.
  respond ~r/./i, msg, state do
    should_execute = state.responders
                     |> Enum.count(fn {regex, _} -> Regex.match?(regex, msg.text) end)

    if should_execute == 1 do
      reply msg, state
                 |> Koala.Robot.Slack.all_usage()
                 |> Enum.reverse()
                 |> Enum.map_join("\n", &(&1))
    else
      :ok
    end

  end

end