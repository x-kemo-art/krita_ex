# KritaEx

[![Hex.pm](https://img.shields.io/hexpm/v/krita_ex.svg)](https://hex.pm/packages/krita_ex) 
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/krita_ex)

A module for extracting embedded images from Krita .kra files

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `krita_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:krita_ex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex(1)> KritaEx.read_png("./priv/test.kra")
{:ok,
<<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 9, 196,
  0, 0, 9, 196, 8, 6, 0, 0, 0, 46, 115, 245, 61, 0, 0, 0, 9, 112, 72, 89, 115,
  0, 0, 46, 35, 0, 0, 46, ...>>}
```

```elixir
iex(1)> KritaEx.extract_png("./priv/test.kra", "./tmp/output.png")
:ok
```
