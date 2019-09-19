defmodule Koala.Release.Train.Team.List do

  require Logger

  def get() do
    {:ok, list} = Clubhouse.Api.get_project_list()
    list.body
    |> Enum.filter(fn project -> project["archived"] == false end)
  end

end
