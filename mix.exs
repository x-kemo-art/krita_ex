defmodule KritaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :krita_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "KritaEx",
      source_url: "https://github.com/x-kemo-art/krita_ex",
      docs: &docs/0
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "KritaEx",
      logo: "priv/logo.svg",
      extras: ["README.md"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37.3", only: :dev, runtime: false}
    ]
  end
end
