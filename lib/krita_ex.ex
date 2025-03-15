defmodule KritaEx do
  @moduledoc """
  Provides functions to extract embedded images from Krita .kra files
  """

  @doc """
  Extracts the embedded png to a specified location

  ## Parameters

    - kra: Path to .kra file or binary content (use of `raw` is required to use binary)
    - out_path: Output filepath
    - options:
      - raw: expect binary input (default `false`)
      - create_dirs: create output directories (default `true`)

  Returns `:ok` or `{:error, reason}`.

  ## Examples

      iex> KritaEx.extract_png("test/files/test.kra", "tmp/output.png")
      :ok

      iex> KritaEx.extract_png("idontexist.kra", "tmp/output.png")
      {:error, {:failed_read, :enoent}}

  """

  def extract_png(kra, out_path, options \\ []) do
    defaults = [create_dirs: true, raw: false]

    %{create_dirs: create_dirs, raw: raw} =
      Keyword.merge(defaults, options) |> Enum.into(%{})

    extract_png(kra, out_path, create_dirs, raw)
  end

  defp extract_png(kra, out_path, create_dirs, raw)

  defp extract_png(kra, out_path, create_dirs, false) when is_binary(kra),
    do: extract_png(:binary.bin_to_list(kra), out_path, create_dirs, false)

  defp extract_png(kra, out_path, create_dirs, raw) do
    with {:ok, binary} <- read_png(kra, raw: raw),
         :ok <- create_file_dir(out_path, create_dirs) do
      write(out_path, binary)
    end
  end

  @doc """
    Aliased to `read_png/2` with `raw: false`
  """

  def read_png(kra), do: read_png(kra, raw: false)

  @doc """
  Reads the embedded png in binary format

  ## Parameters

    - kra: Path to .kra file or file contents (use of `raw` is required to use binary)
    - options:
      - raw: expect binary input (default: `false`, see `read_png/1`)

  ## Examples

      KritaEx.read_png("test/files/test.kra")
      {:ok,
        <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 64, 0,
          0, 0, 64, 8, 6, 0, 0, 0, 170, 105, 113, 222, 0, 0, 0, 9, 112, 72, 89, 115, 0,
          0, 46, 35, 0, 0, 46, ...>>}

  """

  def read_png(kra, raw: false) when is_binary(kra),
    do: read_png(:binary.bin_to_list(kra), raw: false)

  def read_png(kra, raw: _) do
    with {:ok, files} <- list_files(kra),
         :ok <- check_merged_file_exists(files) do
      extract_merged_file(kra)
    end
  end

  @doc """
    Aliased to `valid_kra?/2` with `raw: false`
  """

  def valid_kra?(kra), do: valid_kra?(kra, raw: false)

  @doc """
  Verifies that the supplied .kra is valid

  ## Parameters

    - kra: Path to .kra file or file contents (use of `raw` is required to use binary)
    - options:
      - raw: expect binary input (default: `false`, see `valid_kra?/1`)

  Returns `true` or `false`

  ## Examples

      iex(1)> KritaEx.valid_kra?("test/files/test.kra")
      true

      iex(1)> KritaEx.valid_kra?("test/files/invalid.kra")
      false

  """
  def valid_kra?(kra, raw: false) when is_binary(kra),
    do: valid_kra?(:binary.bin_to_list(kra), raw: false)

  def valid_kra?(kra, raw: _) do
    result =
      with {:ok, files} <- list_files(kra) do
        check_merged_file_exists(files)
      end

    case result do
      :ok -> true
      _ -> false
    end
  end

  defp list_files(kra_path) do
    case :zip.list_dir(kra_path) do
      {:ok, _} = resp -> resp
      {:error, :bad_eocd} -> {:error, :invalid_kra}
      {:error, errcode} -> {:error, {:failed_read, errcode}}
    end
  end

  defp check_merged_file_exists(files) do
    merged_image_file =
      files
      |> Enum.find(
        &case &1 do
          {:zip_file, ~c"mergedimage.png", _, _, _, _} -> true
          _ -> false
        end
      )

    case merged_image_file do
      nil -> {:error, :invalid_kra}
      _ -> :ok
    end
  end

  defp extract_merged_file(kra_path) do
    result =
      :zip.unzip(
        kra_path,
        [
          {:file_list, [~c"mergedimage.png"]},
          :memory
        ]
      )

    case result do
      {:ok, [{_filename, binary}]} -> {:ok, binary}
      {:error, errcode} -> {:error, {:failed_extract, errcode}}
    end
  end

  defp create_file_dir(_, false), do: :ok

  defp create_file_dir(filepath, true) do
    dir = Path.dirname(filepath)

    case File.mkdir_p(dir) do
      {:error, errcode} -> {:error, {:failed_mkdir, errcode}}
      :ok -> :ok
    end
  end

  defp write(out_path, binary) do
    case File.write(out_path, binary) do
      :ok -> :ok
      {:error, errcode} -> {:error, {:failed_write, errcode}}
    end
  end
end
