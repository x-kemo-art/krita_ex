defmodule KritaEx do
  @moduledoc """
  Provides the functions `extract_png/3` and `read_png/1` to extract image data from .kra files.
  """

  @doc """
  Extracts the embedded 'mergedimage.png' inside a .kra file to a specified location

  ## Parameters

    - kra_path: Path to .kra file
    - out_path: Output filepath
    - create_dirs: Automatically create parent directories?

  Returns `:ok`.

  ## Examples

      iex> KritaEx.extract_png("./test/test.kra", "./tmp/output.png")
      :ok

  """

  def extract_png(kra_path, out_path, create_dirs \\ true)

  def extract_png(kra_path, out_path, create_dirs) when is_binary(kra_path),
    do: extract_png(:binary.bin_to_list(kra_path), out_path, create_dirs)

  def extract_png(kra_path, out_path, create_dirs) do
    with {:ok, binary} <- read_png(kra_path),
         :ok <- create_file_dir(out_path, create_dirs) do
      write(out_path, binary)
    end
  end

  @doc """
  Reads the embedded 'mergedimage.png' inside a .kra file

  ## Parameters

    - kra_path: Path to .kra file

  Returns `{:ok, binary()}`.

  ## Examples

      iex(1)> KritaEx.read_png("./priv/test.kra")
      {:ok,
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 9, 196,
        0, 0, 9, 196, 8, 6, 0, 0, 0, 46, 115, 245, 61, 0, 0, 0, 9, 112, 72, 89, 115,
        0, 0, 46, 35, 0, 0, 46, ...>>}

  """

  def read_png(kra_path) when is_binary(kra_path),
    do: read_png(:binary.bin_to_list(kra_path))

  def read_png(kra_path) do
    with {:ok, files} <- list_files(kra_path),
         :ok <- check_merged_file_exists(files) do
      extract_merged_file(kra_path)
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
