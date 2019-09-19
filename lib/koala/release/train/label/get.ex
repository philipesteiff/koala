defmodule Koala.Release.Train.Label.Get do

  def get_label_by_version(version) do
    {:ok, list} = Clubhouse.Api.get_label_list()

    list.body
    |> Enum.filter(fn label -> Clubhouse.Helper.is_valid_label(label) end)
    |> Enum.find(
         nil,
         fn label ->
           Clubhouse.Helper.get_label_version(label) == version
         end
       )
  end

end
