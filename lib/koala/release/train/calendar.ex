defmodule Koala.Release.Train.Calendar do

  use Timex
  require Logger

  def get_schedules() do
    calendar_id = Google.Calendar.get_calendar_id_by_name(Koala.Application.env(:google_calendar_name))
    get_next_release_train_schedules(calendar_id)
  end

  defp get_next_release_train_schedules(calendar_id) do

    # Remove it from here
    today = today()

    time_max = today
               |> Timex.shift(days: 30)

    time_min = today
               |> Timex.shift(days: -15)

    {:ok, events} = Google.Calendar.get_calendar_events_by_calendar_id(calendar_id, time_max, time_min)
    {:ok, items} = Map.fetch(events, :items)

    filter_release_train_events(items)
  end

  defp filter_release_train_events(events) do

    # Upcoming train
    upcoming_events = get_next_events(events, today())
    upcoming_release_event = get_next_release_event(upcoming_events)
    upcoming_code_freeze_event = get_next_code_freeze_event(events, upcoming_release_event)

    # Future Train
    next_events = get_next_events(upcoming_events, upcoming_release_event.start.date)
    next_release_event = get_next_release_event(next_events)
    next_code_freeze_event = get_next_code_freeze_event(events, next_release_event)

    upcoming_version = case Koala.Helper.Version.extract_version(upcoming_release_event.summary) do
      {:ok, extracted_version} -> extracted_version
      {:not_found, _} -> nil
    end

    next_version = case Koala.Helper.Version.extract_version(next_release_event.summary) do
      {:ok, extracted_version} -> extracted_version
      {:not_found, _} -> nil
    end

    schedules = %{
      upcoming: %{
        id: upcoming_release_event.id,
        version: %{
          name: upcoming_version
        },
        code_freeze_event: %{
          name: upcoming_code_freeze_event.summary,
          date: upcoming_code_freeze_event.start.date
        },
        release_event: %{
          name: upcoming_release_event.summary,
          date: upcoming_release_event.start.date
        },
      },
      next: %{
        id: next_release_event.id,
        version: %{
          name: next_version
        },
        code_freeze_event: %{
          name: next_code_freeze_event.summary,
          date: next_code_freeze_event.start.date
        },
        release_event: %{
          name: next_release_event.summary,
          date: next_release_event.start.date
        }
      }
    }

    #    Logger.info(
    #      "Events Result: #{inspect schedules, pretty: true, limit: :infinity}"
    #    )

    schedules
  end

  defp get_next_events(events, date) do
    events
    |> Enum.filter(
         fn event -> Timex.after?(event.start.date, date) end
       )
  end

  defp get_next_release_event(events) do
    events
    |> Enum.find(
         nil,
         fn event ->
           event.summary
           |> String.match?(~r/([\w*-]\.)([\w*-]\.)([\w*-])/)
         end
       )
  end

  defp get_next_code_freeze_event(events, release_event) do
    events
    |> Enum.filter(
         fn event -> Timex.before?(event.start.date, release_event.start.date) end
       )
    |> Enum.reverse()
    |> Enum.find(
         nil,
         fn event ->
           event.summary
           |> String.match?(~r/^#{Koala.Application.env(:google_calendar_code_freeze_name)}/)
         end
       )
  end


  # Time helpers

  defp today() do
    Timex.now("Europe/Madrid")
    |> Timex.beginning_of_day()
  end

end
