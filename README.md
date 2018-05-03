# POAAgent

**TODO: Add description**

## Run

POAAgent is an Elixir application, in order to run it first we need to fetch the dependencies and compile it.

```
mix deps.get
mix deps.compile
mix compile
```

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