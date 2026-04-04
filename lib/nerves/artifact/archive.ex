# SPDX-FileCopyrightText: 2018 Justin Schneck
# SPDX-FileCopyrightText: 2018 Michael Schmidt
# SPDX-FileCopyrightText: 2022 Frank Hunleth
# SPDX-FileCopyrightText: 2022 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Nerves.Artifact.Archive do
  @moduledoc false

  @doc """
  Returns the list of supported archive extensions
  """
  @spec supported_extensions() :: [String.t()]
  def supported_extensions() do
    [".tar.gz", ".tar.xz"]
  end

  @doc """
  Return true if the path looks like it could be an archive

  This is a simplistic test that only looks at the name. Call
  `validate/1` to check the contents.
  """
  @spec valid_name?(String.t()) :: boolean()
  def valid_name?(path) do
    Enum.any?(supported_extensions(), &String.ends_with?(path, &1))
  end

  @doc """
  Extract tar file entries to a directory
  """
  @spec extract(String.t(), String.t()) :: :ok | {:error, any}
  def extract(file, destination) when is_binary(file) and is_binary(destination) do
    cmd("tar", ["xf", file, "--strip-components=1", "-C", destination])
    |> result()
  end

  @doc """
  Check an artifact archive for corruption

  Returns `:ok`, if a valid artifact.
  """
  @spec validate(String.t()) :: :ok | {:error, any}
  def validate(path) do
    case detect_compression(path) do
      :xz -> cmd("xz", ["-t", path]) |> result()
      :gzip -> cmd("gzip", ["-t", path]) |> result()
      _other -> {:error, "Unsupported artifact format for #{path}"}
    end
  end

  defp result({"", 0}), do: :ok
  defp result({reason, _}), do: {:error, reason}

  defp cmd(cmd, args) do
    if System.find_executable(cmd) do
      System.cmd(cmd, args, stderr_to_stdout: true)
    else
      raise "Could not find '#{cmd}'. See https://hexdocs.pm/nerves/installation.html for required packages."
    end
  end

  defp detect_compression(path) do
    with {:ok, fd} <- File.open(path, [:read, :binary]),
         bytes <- IO.binread(fd, 6),
         :ok <- File.close(fd) do
      compression_from_magic_bytes(bytes)
    else
      _ -> :error
    end
  end

  defp compression_from_magic_bytes(<<0x1F, 0x8B, _::binary>>), do: :gzip
  defp compression_from_magic_bytes(<<0xFD, "7zXZ", _::binary>>), do: :xz
  defp compression_from_magic_bytes(<<0x28, 0xB5, 0x2F, 0xFD, _::binary>>), do: :zstd
  defp compression_from_magic_bytes(_), do: :unknown
end
