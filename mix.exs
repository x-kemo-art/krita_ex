defmodule KritaEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/x-kemo-art/krita_ex"

  def project do
    [
      app: :krita_ex,
      version: "0.1.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "KritaEx",
      description: "A module for extracting embedded images from Krita .kra files",
      source_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["x_kemo"],
      links: %{
        "GitHub" => @source_url
      }
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
