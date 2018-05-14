defmodule POAAgent.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :poa_agent,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {POAAgent.Application, []}
    ]
  end

  defp deps do
    [
      {:ethereumex, "~> 0.3"},

      # Tests
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:mock, "~> 0.3", only: [:test], runtime: false},

      # Docs
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "POAAgent.Application",
      source_url: "https://github.com/poanetwork/poa-netstats-agent",
      groups_for_modules: [
        "Plugins": [
          POAAgent.Plugins.Collector,
          POAAgent.Plugins.Transfer,
        ],
        "Ethereum Plugins": [
          POAAgent.Plugins.Collectors.Eth.LatestBlock,
          POAAgent.Plugins.Collectors.Eth.Stats
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
