#!/usr/bin/env pwsh

#################
# Install gitea #
#################

# Every package should define these variables
$pkg_cmd_name = "gitea"

$pkg_dst_cmd = "$Env:USERPROFILE\.local\bin\gitea.exe"
$pkg_dst = "$pkg_dst_cmd"

$pkg_src_cmd = "$Env:USERPROFILE\.local\opt\gitea-v$Env:WEBI_VERSION\bin\gitea.exe"
$pkg_src_bin = "$Env:USERPROFILE\.local\opt\gitea-v$Env:WEBI_VERSION\bin"
$pkg_src_dir = "$Env:USERPROFILE\.local\opt\gitea-v$Env:WEBI_VERSION"
$pkg_src = "$pkg_src_cmd"

$pkg_download = "$Env:USERPROFILE\Downloads\$Env:WEBI_PKG_FILE"

# Fetch archive
IF (!(Test-Path -Path "$Env:USERPROFILE\Downloads\$Env:WEBI_PKG_FILE"))
{
    # TODO: arch detection
    echo "Downloading gitea from $Env:WEBI_PKG_URL to $pkg_download"
    & curl.exe -A "$Env:WEBI_UA" -fsSL "$Env:WEBI_PKG_URL" -o "$pkg_download.part"
    & move "$pkg_download.part" "$pkg_download"
}

IF (!(Test-Path -Path "$pkg_src_cmd"))
{
    echo "Installing gitea"

    # TODO: create package-specific temp directory
    # Enter tmp
    pushd .local\tmp

    	# Remove any leftover tmp cruft
        Remove-Item -Path ".\gitea-*" -Recurse -ErrorAction Ignore
        Remove-Item -Path ".\gitea.exe" -Recurse -ErrorAction Ignore

        # Move single binary into root of temporary folder
        & move "$Env:USERPROFILE\Downloads\$Env:WEBI_PKG_FILE" "gitea.exe"

        # Settle unpacked archive into place
        echo "Install Location: $pkg_src_cmd"
        New-Item "$pkg_src_bin" -ItemType Directory -Force | out-null
        Move-Item -Path "gitea.exe" -Destination "$pkg_src_bin"

    # Exit tmp
    popd
}

echo "Copying into '$pkg_dst_cmd' from '$pkg_src_cmd'"
Remove-Item -Path "$pkg_dst_cmd" -Recurse -ErrorAction Ignore | out-null
Copy-Item -Path "$pkg_src" -Destination "$pkg_dst" -Recurse