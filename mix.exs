Code.ensure_loaded?(Hex) and Hex.start

defmodule Dropbox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dropbox,
      version: "0.0.7",
      elixir: "~> 1.2.0",
      description: description,
      package: package,
      deps: deps
    ]
  end

  def application do
    [
      mod: { Dropbox, [] },
      applications: [:hackney, :httpoison]
    ]
  end

  defp deps do
    [
      {:jazz, "~> 0.2.1"},
      {:hackney, "~> 1.4.4"},
      {:httpoison, "~> 0.8.0"}
    ]
  end

  defp description do
    "A Dropbox Core API client for Elixir"
  end

  defp package do
    [
      contributors: ["Amir Malik"],
      licenses: ["MIT"],
      links: [
        {"GitHub", "https://github.com/ammmir/elixir-dropbox"}
      ]
    ]
  end
end
