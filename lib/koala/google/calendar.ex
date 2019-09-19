defmodule Google.Calendar do

  def get_calendar_id_by_name(calendar_name) do
    {:ok, calendars} = GoogleApi.Calendar.V3.Api.CalendarList.calendar_calendar_list_list(get_connection())
    {:ok, items} = Map.fetch(calendars, :items)
    [calendar] = Enum.filter(items, fn (x) -> {:ok, calendar_name} == Map.fetch(x, :summary) end)
    Map.fetch!(calendar, :id)
  end

  def get_calendar_events_by_calendar_id(calendar_id, time_max, time_min) do
    GoogleApi.Calendar.V3.Api.Events.calendar_events_list(
      get_connection(),
      calendar_id,
      [
        {:timeMax, format_time_to_RFC3339(time_max)},
        {:timeMin, format_time_to_RFC3339(time_min)},
        {:singleEvents, true},
        {:orderBy, "startTime"}
      ]
    )
  end

  defp get_token() do
    {:ok, map} = Goth.Token.for_scope("https://www.googleapis.com/auth/calendar")
    Map.fetch!(map, :token)
  end


  defp get_connection() do
    GoogleApi.Calendar.V3.Connection.new(get_token())
  end

  defp format_time_to_RFC3339(datetime) do
    datetime
    |> Timex.format("{RFC3339}")
    |> elem(1)
  end

end
