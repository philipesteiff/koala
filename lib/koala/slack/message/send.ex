defmodule Koala.Slack.Message.Send do

  def send_message(text) do
    # Create a Hedwig message
    msg = %Hedwig.Message{
      type: "message",
      room: channel_id(Koala.Application.env(:bot_slack_channel)),
      text: text
    }

    # Send the message
    Hedwig.Robot.send(pid(), msg)
  end

  def channel_id(name) do
    {id, _} =
      channels()
      |> Stream.map(fn {_x, %{"id" => id, "name" => name}} -> {id, name} end)
      |> Enum.find({nil, nil}, fn {_, channel} -> channel === name end)
    id
  end

  def channels() do
    %Hedwig.Robot{adapter: apid} = pid()
                                   |> :sys.get_state()
    slack_state = apid
                  |> :sys.get_state
                  |> Map.from_struct

    slack_state
    |> Map.get(:channels, %{})
    |> Map.merge(Map.get(slack_state, :groups, %{}))
  end

  defp pid, do: :global.whereis_name(Koala.Application.env(:bot_name))

end
