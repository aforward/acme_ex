# AcmeEx

Run a local Let's Encrypt Acme verifier.

This was heavily influence by [site_encrypt](https://github.com/sasa1977/site_encrypt) from [Saša Jurić](https://github.com/sasa1977)
which provides integrated certificate renewal within your
Phoenix app.

To run the server, you can use mix

```
mix acme.server --port <4002>
```

Or, you can start the server from iex (for example) using

```elixir
iex -S mix
Erlang/OTP 20 [erts-9.3.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.6.5) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> AcmeEx.Standalone.start_link()
{:ok, #PID<0.198.0>}
```

To supervise this server, you can add it to your supervised
children by calling,

    AcmeEx.Standalone.child_spec(opts)

Or, you can add the children specs directly to your supervisor

    AcmeEx.Standalone.children_specs(opts)


## Installation

```elixir
@deps [
  acme_ex: "~> 0.4.0"
]
```

## License

Source code is licensed under [MIT](LICENSE)

----
Created:  2018-05-26Z
