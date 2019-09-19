defmodule Koala.Release.Train.Status.Render do

  require Logger

  def inform_train_status do
    Koala.Slack.Message.Send.send_message("Retrieving Train information status... (triggered via cron)")
    Koala.Slack.Message.Send.send_message(get_train_report(:slack))
  end

  def get_train_report(service) do
    case service do
      :slack -> build_train_report(Koala.Release.Train.MessageFormatter.Slack)
      :gitlab -> build_train_report(Koala.Release.Train.MessageFormatter.Gitlab)
    end
  end

  def build_train_report(formatter) do
    formatter.render()
  end

end
