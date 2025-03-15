defmodule KritaExTest do
  use ExUnit.Case

  @expected_png_hash <<148, 200, 172, 107, 239, 89, 96, 126, 249, 79, 161, 244, 105, 216, 255, 39,
                       37, 243, 95, 168, 20, 217, 138, 49, 34, 102, 3, 124, 161, 198, 125, 92>>

  @hash_algorithm :sha256

  @test_file "test/files/test.kra"
  @invalid_test_bin "test/files/invalid.bin"
  @invalid_test_kra "test/files/invalid.kra"
  @output_path_no_dir "tmp/out.png"
  @output_path_create_dir "tmp/krita_ex_test/out.png"
  @output_dir_cleanup "tmp/krita_ex_test"
  @invalid_path "/this/path/should/not/exist"

  defp check_hash(bytes) do
    :crypto.hash(@hash_algorithm, bytes) == @expected_png_hash
  end

  test "read png from filepath" do
    {:ok, bytes} = KritaEx.read_png(@test_file)
    assert check_hash(bytes)
  end

  test "read png from bytes" do
    {:ok, kra_bytes} = File.read(@test_file)
    {:ok, png_bytes} = KritaEx.read_png(kra_bytes, raw: true)
    assert check_hash(png_bytes)
  end

  test "extract png from filepath, not creating directories" do
    File.mkdir("tmp")

    :ok =
      KritaEx.extract_png(
        @test_file,
        @output_path_no_dir,
        create_dirs: false
      )

    {:ok, bytes} = File.read(@output_path_no_dir)
    assert check_hash(bytes)

    :ok = File.rm(@output_path_no_dir)
  end

  test "extract png from filepath, creating directories" do
    :ok = KritaEx.extract_png(@test_file, @output_path_create_dir)
    {:ok, bytes} = File.read(@output_path_create_dir)
    assert check_hash(bytes)

    {:ok, _} = File.rm_rf(@output_dir_cleanup)
  end

  test "extract png from bytes, not creating directories" do
    File.mkdir("tmp")

    {:ok, kra_bytes} = File.read(@test_file)

    :ok =
      KritaEx.extract_png(
        kra_bytes,
        @output_path_no_dir,
        raw: true,
        create_dirs: false
      )

    {:ok, bytes} = File.read(@output_path_no_dir)
    assert check_hash(bytes)

    :ok = File.rm(@output_path_no_dir)
  end

  test "extract png from bytes, creating directories" do
    {:ok, kra_bytes} = File.read(@test_file)

    :ok =
      KritaEx.extract_png(
        kra_bytes,
        @output_path_create_dir,
        raw: true
      )

    {:ok, bytes} = File.read(@output_path_create_dir)
    assert check_hash(bytes)

    {:ok, _} = File.rm_rf(@output_dir_cleanup)
  end

  test "validate .kra file" do
    assert KritaEx.valid_kra?(@test_file)
  end

  # negative cases

  test "extract from non-existent file; invoke read failure" do
    result =
      KritaEx.extract_png(
        @invalid_path,
        @output_path_no_dir
      )

    assert result == {:error, {:failed_read, :enoent}}
  end

  test "extract to non-existent path; invoke mkdir failure" do
    result =
      KritaEx.extract_png(
        @test_file,
        @invalid_path
      )

    assert result == {:error, {:failed_mkdir, :enoent}}
  end

  test "write to dir; invoke write failure" do
    File.mkdir(@output_dir_cleanup)

    result =
      KritaEx.extract_png(
        @test_file,
        @output_dir_cleanup
      )

    assert result == {:error, {:failed_write, :eisdir}}

    File.rmdir(@output_dir_cleanup)
  end

  test "read invalid .kra file" do
    result =
      KritaEx.extract_png(
        @invalid_test_bin,
        @output_path_no_dir
      )

    assert result == {:error, :invalid_kra}
  end

  test "validate invalid .kra file (non-zip)" do
    assert !KritaEx.valid_kra?(@invalid_test_bin)
  end

  test "validate invalid .kra file (zip)" do
    assert !KritaEx.valid_kra?(@invalid_test_kra)
  end

  doctest KritaEx
end
