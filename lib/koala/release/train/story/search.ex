defmodule Koala.Clubhouse.Story.Search do

  def get_stories_by_label(label_name) do
    {:ok, stories_response} = Clubhouse.Api.search_stories_by_label(label_name)
    stories_response.body["data"]
  end

end
