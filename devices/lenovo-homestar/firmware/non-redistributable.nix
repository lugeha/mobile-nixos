{ lib
, runCommand
, fetchzip
, util-linux
, p7zip
}:

runCommand "lenovo-homestar-unredistributable-firmware" {
  nativeBuildInputs = [
    p7zip
    util-linux
  ];
  src = fetchzip {
    url = "https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_15278.72.0_strongbad_recovery_stable-channel_mp-v5.bin.zip";
    sha256 = "sha256-LJmtQmlHcFhKmpUxm6bEpWmIS5OPtju2+zT9AmMEo8U=";
  };
  meta.license = [
    # We make no claims that it can be redistributed.
    # The modem files, needed to start the Wi-Fi bits, are not clearly licensed for distribution.
    lib.licenses.unfree
  ];
} ''
  disk_image=$(echo $src/*)
  part="ROOT-A"

  echo ":: Extracting $part from ChromeOS image"

  eval "$(
      sfdisk --dump "$disk_image" | grep "$part" | sed -e 's/,\s*/;/g' -e 's/\s*=\s*/=/g' -e 's/^.*\s:\s//'
  )"

  echo ":: Extracting firmware files from $part"

  (
  PS4=" $ "
  set -x
  dd bs=512 if="$disk_image" of="$part" skip="$start" count="$size"
  7z x -o"$out" "$part" "lib/firmware/qcom/sc7180-trogdor"
  )
''
