defmodule Koala.Helper.Version do

  def extract_version(text) do
    case Regex.run(~r/\d+(\.\d+)+/, text) do
      nil ->
        {:not_found, "Version not found"}
      matches ->
        match = matches
                |> List.first
        {:ok, match}
    end
  end

end
