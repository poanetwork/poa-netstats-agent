defmodule POAAgent.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :poa_agent,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {POAAgent.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/ancillary"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:ethereumex, "~> 0.3"},
      {:poison, "~> 3.1"},
      {:msgpax, "~> 2.1"},

      # Tests
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:mock, "~> 0.3", only: [:test], runtime: false},
      {:excoveralls, "~> 0.8", only: [:test, :dev], runtime: false},

      # Docs
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},

      # Transfer
      {:websockex, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:backoff, "~> 1.1"},

      # Releases
      {:distillery, "~> 1.5", runtime: false}
    ]
  end

  defp docs do
    [
      main: POAAgent,
      source_ref: "v#{@version}",
      source_url: "https://github.com/poanetwork/poa-netstats-agent",
      extras: [
        "pages/initial_architecture.md": [filename: "initial_architecture", title: "Initial Architecture"],
        "pages/starting_guide.md": [filename: "starting_guide", title: "Getting Started"]
        ],
      groups_for_modules: [
        "Plugins": [
          POAAgent.Plugins.Collector,
          POAAgent.Plugins.Transfer,
        ],
        "Ethereum Plugins": [
          POAAgent.Plugins.Collectors.Eth.LatestBlock,
          POAAgent.Plugins.Collectors.Eth.Stats,
          POAAgent.Plugins.Collectors.Eth.Pending,
          POAAgent.Plugins.Collectors.Eth.Information
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      paths: [
        "_build/#{Mix.env()}/lib/poa_agent/consolidated"
      ]
    ]
  end
end
