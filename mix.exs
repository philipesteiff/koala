defmodule Koala.MixProject do
  use Mix.Project

  def project do
    [
      app: :koala,
      version: "0.1.0",
      elixir: "1.8.1",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:hedwig_slack, :hedwig, :logger, :timex],
      mod: {Koala.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.2.1"},
      {:jason, ">= 1.0.0"},
      {:fastglobal, "~> 1.0"},
      {:timex, "~> 3.6.1"},

      # Cron
      {:quantum, "~> 2.3.4"},

      # Bota Api
      {:hedwig, "~> 1.0.1"},
      {:hedwig_slack, "~> 1.0"},

      # Google Apis
      {:goth, "~> 1.1.0"},
      {:google_api_calendar, "~> 0.6.1"},
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
