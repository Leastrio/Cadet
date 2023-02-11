defmodule Cadet.MixProject do
  use Mix.Project

  def project do
    [
      app: :cadet,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      name: "Cadet",
      source_url: "https://github.com/Leastrio/Cadet",
      package: package(),
      docs: docs()
    ]
  end

  defp docs do
    [
      main: "Cadet"
    ]
  end

  defp package do
    [
      name: :cadet,
      licenses: ["MIT"],
      maintainers: ["Leastrio"],
      links: %{
        "Github" => "https://github.com/Leastrio/Cadet"
      }
    ]
  end

  defp description do
    "A command handler for the Nostrum discord API wrapper"
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
