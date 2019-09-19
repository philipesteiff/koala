defmodule Gitlab.Helper do

  @project_milestones_url "#{Koala.Application.env(:gitlab_base_url)}/#{Koala.Application.env(:gitlab_project_path)}/-/milestones/"

  def find_milestone(milestones, query) do
    milestones
    |> Enum.find(
         nil,
         fn milestone -> String.contains?(milestone["title"], query) end
       )
  end

  def get_milestone_url(milestone_iid) do
    "#{@project_milestones_url}#{milestone_iid}"
  end

end
