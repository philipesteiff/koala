defmodule Koala.Robot.Slack do
  use Hedwig.Robot, otp_app: :koala

  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  def handle_in(%Hedwig.Message{} = msg, state) do
    {:dispatch, msg, state}
  end

  def handle_in(_msg, state) do
    {:noreply, state}
  end

  # Hack to get all helpers
  def all_usage(%{name: name, robot: robot}) do
    responders = Hedwig.Robot.responders(robot)
    Enum.reduce responders, [], fn {mod, _opts}, acc ->
      mod.usage(name) ++ acc
    end
  end

end
