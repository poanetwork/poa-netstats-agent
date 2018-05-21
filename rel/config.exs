use Mix.Releases.Config,
    default_release: :poa_agent,
    default_environment: :prod

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"O*Ke`PUEMlN@H@XJWeV6:(@rsc!]Rh^RhxfuNysi6eYr%<rZ./V4%DVh]N}Xbc?,"
end

release :poa_agent do
  set version: current_version(:poa_agent)
  set applications: [
    :runtime_tools
  ]
end

