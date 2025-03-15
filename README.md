<h1><img align="center" height="60" src="priv/logo.svg"> KritaEx</h1>

![Build Status](https://github.com/x-kemo-art/krita_ex/actions/workflows/elixir.yml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/krita_ex.svg)](https://hex.pm/packages/krita_ex) 
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/krita_ex)

A module for extracting embedded images from Krita .kra files

## Installation

This package can be installed
by adding `krita_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:krita_ex, "~> 0.1.1"}
  ]
end
```

## Usage

```elixir
iex(1)> KritaEx.extract_png("test/files/test.kra", "tmp/output.png")
:ok
```

```elixir
iex(1)> KritaEx.read_png("test/files/test.kra")
{:ok,
  <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 64, 0,
    0, 0, 64, 8, 6, 0, 0, 0, 170, 105, 113, 222, 0, 0, 0, 9, 112, 72, 89, 115, 0,
    0, 46, 35, 0, 0, 46, ...>>}
```

```elixir
iex(1)> KritaEx.valid_kra?("test/files/test.kra")
true

iex(2)> KritaEx.valid_kra?("test/files/invalid.kra")
false
```
