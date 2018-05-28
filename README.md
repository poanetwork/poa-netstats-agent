# POAAgent

[![Coverage Status](https://coveralls.io/repos/github/poanetwork/poa-netstats-agent/badge.svg?branch=master)](https://coveralls.io/github/poanetwork/poa-netstats-agent?branch=master)
[![codecov](https://codecov.io/gh/poanetwork/poa-netstats-agent/branch/master/graph/badge.svg)](https://codecov.io/gh/poanetwork/poa-netstats-agent)

**TODO: Add description**

## Documentation

In order to create the documentation

```
mix docs
```

## Run

POAAgent is an Elixir application, in order to run it first we need to fetch the dependencies and compile it.

```
mix deps.get
mix deps.compile
mix compile
```

To run the Elixir application while under development it may be convenient to use:
`env MIX_ENV=dev mix run --no-halt` with an appropiate configuration in `/config/dev.exs`.

## Run Tests

In order to run the tests we have to run the command

```
mix test
```

`POAAgent` comes also with a code analysis tool [Credo](https://github.com/rrrene/credo) and a types checker tool [Dialyxir](https://github.com/jeremyjh/dialyxir). In order to run them we have to run

```
mix credo
mix dialyzer
```

## Building & Deploying an Executable

To build an executable you'll need Elixir 1.6 (and Erlang/OTP 20).

1. Once you have a copy of this repository configure the agent for production in the file `config/prod.exs`.
2. An example configuration can be found in `config/test.exs`.
3. Do a `mix deps.get` to fetch, among other dependencies, the tooling for building server executables.
4. A `env MIX_ENV=prod mix release --name=poa_agent --env=prod` will assemble an executable.

A resulting artifact resides at `_build/prod/rel/poa_agent/releases/0.1.0/poa_agent.tar.gz` which you can move to a remote host.
Use `tar xfz` then `bin/poa_agent start` (`bin/poa_agent stop` will stop the server cleanly).

If you want to run it on the local host then the procedure is as simple as: `_build/prod/rel/poa_agent/bin/poa_agent`.

**Note:** executables must be built on the platform (OS and architecture) they are destined for under the project's current configuration.
Other options are possible (see `https://hexdocs.pm/distillery/getting-started.html`).

## Configuration

Executables are built with a configuration as described above.
However the Primus/WebSocket transfer is configurable at run-time through a JSON configuration.
To configure this supply a path to a JSON file with the `transfer_config_overlay` key/value.
The following is an extract from [config/test.exs](config/test.exs):

```Elixir
config :poa_agent,
    transfer_config_overlay: "config/transfer_overlay.json"
```

A corresponding example is provided in `config/transfer_overlay.json`:

```JSON
{
    "POAAgent":{
        "transfers":[
            {
                "id":"node_integration",
                "address":"ws://localhost:3000/api",
                "identifier":"elixirNodeJSIntegration",
                "name":"Elixir-NodeJS-Integration",
                "secret":"Fr00b5",
                "contact":"a@b.c"
            }
        ]
    }
}

```

The file can reside anywhere on the machine that the Elixir executable has access to.
The key/value pairs in the JSON configuration will replace the defaults specified in the Elixir configuration (i.e. `config/{dev,test,prod}.exs`).

## Coverage

To get an HTML coverage report on your own machine try `env MIX_ENV=test mix coveralls.html` then open `cover/excoveralls.html`.
You can get a simple print-out with `env MIX_ENV=test mix coveralls`.
