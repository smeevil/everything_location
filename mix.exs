defmodule EverythingLocation.Mixfile do
  use Mix.Project

  def project do
    [
      app: :everything_location,
      package: package,
      version: "0.0.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger, :httpotion, :poison]]
  end

  defp deps do
    [
      {:ecto, "~> 1.1.8 "},
      {:poison, "~> 2.1.0"},
      {:httpotion, "~>  2.2.2"},
      {:mix_test_watch, ">0.0.0", only: [:dev, :test]},
      {:exvcr, git: "git@github.com:parroty/exvcr.git", only: [:dev, :test]},
      {:credo, ">0.0.0", only: [:dev, :test]}, #vcr
      {:earmark , ">0.0.0"  , only: :dev},
      {:ex_doc  , "> 0.0.0" , only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/everything_location",
        "Docs"   => "http://smeevil.github.io/everything_location/"
      }
    ]
  end
end
