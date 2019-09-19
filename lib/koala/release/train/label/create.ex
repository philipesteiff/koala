defmodule Koala.Release.Train.Label.Create do

  require Logger

  def create_label() do
    schedules = Koala.Release.Train.Calendar.get_schedules()
    version = schedules.upcoming.version.name

    if (has_label(version) == false) do
      label_name = "#{Koala.Application.env(:clubhouse_label_version_prefix)}#{version}"

      Logger.info("Creating missing label: #{inspect label_name, pretty: true, limit: :infinity}")
      Koala.Slack.Message.Send.send_message("Creating label `#{label_name}`... (triggered via cron)")

      case Clubhouse.Api.create_label(label_name) do
        {:ok, _} -> Koala.Slack.Message.Send.send_message("Label `#{label_name}` created :white_check_mark:")
        {:error, _} -> Koala.Slack.Message.Send.send_message("Failed to create `#{label_name}` label.")
      end

    else
      Logger.info("Has label!")
    end

  end

  defp has_label(version) do
    {:ok, list} = Clubhouse.Api.get_label_list()

    list.body
    |> Enum.filter(fn label -> Clubhouse.Helper.is_valid_label(label) end)
    |> Enum.any?(fn label -> Clubhouse.Helper.get_label_version(label) == version end)
  end

end