defmodule Taskerville.MixProject do
  use Mix.Project

  def project do
    [
      app: :taskerville,
      version: "0.0.1",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    """
    A simple cron based task scheduler implementation.
    """
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Zach Welden"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/zwelden/taskerville"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crontab, "~> 1.1"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev, runtime: false}
    ]
  end
end
