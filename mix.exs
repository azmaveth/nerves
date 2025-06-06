defmodule Nerves.MixProject do
  use Mix.Project

  @version "1.11.3"
  @source_url "https://github.com/nerves-project/nerves"

  def project do
    [
      app: :nerves,
      version: @version,
      elixir: "~> 1.14.0 or ~> 1.15.1 or ~> 1.16.0 or ~> 1.17.0 or ~> 1.18.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      docs: docs(),
      dialyzer: dialyzer(),
      preferred_cli_env: %{
        credo: :dev,
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      },
      aliases: ["archive.build": &raise_on_archive_build/1],
      xref: [exclude: [Nerves.Bootstrap]]
    ]
  end

  def application do
    [extra_applications: [:ssl, :inets, :eex, :nerves_bootstrap]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:castore, "~> 0.1 or ~> 1.0"},
      {:elixir_make, "~> 0.6", runtime: false},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:plug, "~> 1.10", only: :test},
      {:mime, "~> 2.0", only: :test},
      {:plug_cowboy, "~> 1.0 or ~> 2.0", only: :test}
    ]
  end

  defp dialyzer do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      plt_add_apps: [:mix]
    ]
  end

  defp docs do
    [
      main: "getting-started",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extra_section: "GUIDES",
      assets: %{"resources" => "assets"},
      logo: "resources/logo-color.png",
      groups_for_extras: [
        Introduction: ~r/guides\/introduction\/.?/,
        Core: ~r/guides\/core\/.?/,
        Advanced: ~r/guides\/advanced\/.?/
      ],
      extras: ["CHANGELOG.md"] ++ Path.wildcard("guides/*/*.md"),
      skip_undefined_reference_warnings_on: [
        "guides/advanced/updating-projects.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp description do
    "Craft and deploy bulletproof embedded software"
  end

  defp package do
    [
      files: [
        "CHANGELOG.md",
        "lib",
        "LICENSES/*",
        "Makefile",
        "mix.exs",
        "NOTICE",
        "README.md",
        "REUSE.toml",
        "scripts",
        "src"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "Home page" => "https://www.nerves-project.org/",
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "REUSE Compliance" => "https://api.reuse.software/info/github.com/nerves-project/nerves"
      }
    ]
  end

  defp raise_on_archive_build(_) do
    Mix.raise("""
    You are trying to install "nerves" as an archive, which is not supported. \
    You probably meant to install "nerves_bootstrap" instead.
    """)
  end
end
