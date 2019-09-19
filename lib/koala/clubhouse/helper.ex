defmodule Clubhouse.Helper do

  def is_valid_label(label), do:
    String.starts_with?(label["name"], Koala.Application.env(:clubhouse_label_version_prefix)) && label["archived"] == false

  def is_valid_epic(epic), do:
    epic["archived"] == false

  def has_label(epic, label_id), do:
    Enum.any?(epic["labels"], fn label -> label["id"] == label_id end)

  def get_label_version(label) do
    label["name"]
    |> String.replace_prefix(Koala.Application.env(:clubhouse_label_version_prefix), "")
  end

end
