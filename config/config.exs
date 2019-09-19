# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :koala, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:koala, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :koala,
       Koala.Application,

       ### Environments variables

       # Gitlab
       gitlab_token: System.get_env("GITLAB_TOKEN"),
       gitlab_base_url: System.get_env("GITLAB_BASE_URL"),
       gitlab_project_path: System.get_env("GITLAB_PROJECT_PATH"),

         # Clubhouse
       clubhouse_token: System.get_env("CLUBHOUSE_API_TOKEN"),
       clubhouse_label_color: System.get_env("CLUBHOUSE_LABEL_COLOR"),
       clubhouse_label_version_prefix: System.get_env("CLUBHOUSE_LABEL_VERSION_PREFIX"),
       clubhouse_company_name: System.get_env("CLUBHOUSE_COMPANY_NAME"),

         # Google Calendar
       google_calendar_name: System.get_env("GOOGLE_CALENDAR_NAME"),
       google_calendar_code_freeze_name: System.get_env("GOOGLE_CALENDAR_CODE_FREEZE_NAME"),

         # Expected env by Goth (set no machine env)
         # GOOGLE_APPLICATION_CREDENTIALS=path/to/google_service_account.json

         # Slack
       slack_token: System.get_env("SLACK_TOKEN"),

         # Bot
       bot_name: System.get_env("BOT_NAME"),
       bot_slack_channel: System.get_env("BOT_SLACK_CHANNEL")


config :koala,
       Koala.Robot.Console,
       adapter: Hedwig.Adapters.Console,
       name: System.get_env("BOT_NAME"),
       aka: "/",
       responders: [
         {Hedwig.Responders.Help, []},
         {Koala.Robot.Responder.ReleaseTrain, []}
       ]

config :koala,
       Koala.Robot.Slack,
       adapter: Hedwig.Adapters.Slack,
       name: System.get_env("BOT_NAME"),
       aka: "/",
         # fill in the appropriate API token for your bot
       token: System.get_env("SLACK_TOKEN"),
         # for now, you can invite your bot to a channel in slack and it will join
         # automatically
       rooms: [],
       responders: [
         {Hedwig.Responders.Help, []},
         {Koala.Robot.Responder.ReleaseTrain, []}
       ]

# Release train configs

config :koala,
       Koala.Release.Train.Scheduler,
       timezone: "Europe/Madrid",
       jobs: [
         update_milestone: [
           schedule: {:extended, "*/60"},
           task: {Koala.Release.Train.Milestone.Update, :update, []}
         ],
         create_label: [
           schedule: {:extended, "*/60"},
           task: {Koala.Release.Train.Label.Create, :create_label, []}
         ],
         inform_train_status: [
           schedule: {:extended, "*/60"},
           task: {Koala.Release.Train.Status.Render, :inform_train_status, []}
         ]
       ]