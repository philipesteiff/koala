defmodule Koala.Release.Train.Milestone.Get do

  def get_all() do
    case Gitlab.Api.get_all_milestones() do
      {:ok, list} -> {:ok, list.body}
      {:error, _} -> {:error, "Failed to retrieve milestones."}
    end
  end

  def get_all_active() do
    case Gitlab.Api.get_all_active_milestones() do
      {:ok, list} -> {:ok, list.body}
      {:error, _} -> {:error, "Failed to retrieve milestones."}
    end
  end


end
