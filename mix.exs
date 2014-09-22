defmodule FakeHttp.Mixfile do
  use Mix.Project

  def project do
    [app: :fake_http,
     version: "0.0.1",
     elixir: ">= 0.14.3",
     deps: deps]
  end

  def application do
    []
  end

  def description do
    "Fake Http Endpoint"
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*"],
      contributors: ["Ayodele Abejide"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bjhaid/fake_http"}
    ]
  end

  defp deps do
  end
end
