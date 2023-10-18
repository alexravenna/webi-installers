#!/usr/bin/env pwsh

#########################
# Install AtomicParsley #
#########################

# Every package should define these variables
$pkg_cmd_name = "AtomicParsley"

$pkg_dst_cmd = "$Env:USERPROFILE\.local\bin\AtomicParsley.exe"
$pkg_dst_bin = "$Env:USERPROFILE\.local\bin"
$pkg_dst = "$pkg_dst_cmd"

$pkg_src_cmd = "$Env:USERPROFILE\.local\opt\AtomicParsley-v$Env:WEBI_VERSION\bin\AtomicParsley.exe"
$pkg_src_bin = "$Env:USERPROFILE\.local\opt\AtomicParsley-v$Env:WEBI_VERSION\bin"
$pkg_src_dir = "$Env:USERPROFILE\.local\opt\AtomicParsley-v$Env:WEBI_VERSION"
$pkg_src = "$pkg_src_cmd"

New-Item "$Env:USERPROFILE\Downloads\webi" -ItemType Directory -Force | Out-Null
$pkg_download = "$Env:USERPROFILE\Downloads\webi\$Env:WEBI_PKG_FILE"

# Fetch archive
IF (!(Test-Path -Path "$Env:USERPROFILE\Downloads\webi\$Env:WEBI_PKG_FILE")) {
    echo "Checking for (or Installing) MSVC Runtime..."
    & "$Env:USERPROFILE\.local\bin\webi-pwsh.ps1" vcruntime

    echo "Downloading AtomicParsley from $Env:WEBI_PKG_URL to $pkg_download"
    & curl.exe -A "$Env:WEBI_UA" -fsSL "$Env:WEBI_PKG_URL" -o "$pkg_download.part"
    & move "$pkg_download.part" "$pkg_download"
}

IF (!(Test-Path -Path "$pkg_src_cmd")) {
    echo "Installing AtomicParsley"

    # TODO: create package-specific temp directory
    # Enter tmp
    pushd .local\tmp

    # Remove any leftover tmp cruft
    Remove-Item -Path ".\AtomicParsley-v*" -Recurse -ErrorAction Ignore
    Remove-Item -Path ".\AtomicParsley.exe" -Recurse -ErrorAction Ignore

    # Unpack archive file into this temporary directory
    # Windows BSD-tar handles zip. Imagine that.
    echo "Unpacking $pkg_download"
    & tar xf "$pkg_download"

    # Settle unpacked archive into place
    echo "Install Location: $pkg_src_cmd"
    New-Item "$pkg_src_bin" -ItemType Directory -Force | Out-Null
    Move-Item -Path ".\AtomicParsley.exe" -Destination "$pkg_src_bin"

    # Exit tmp
    popd
}

echo "Copying into '$pkg_dst_cmd' from '$pkg_src_cmd'"
Remove-Item -Path "$pkg_dst_cmd" -Recurse -ErrorAction Ignore | Out-Null
New-Item "$pkg_dst_bin" -ItemType Directory -Force | Out-Null
Copy-Item -Path "$pkg_src" -Destination "$pkg_dst" -Recurse