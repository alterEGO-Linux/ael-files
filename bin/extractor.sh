#!/usr/bin/env sh
# ------------------------------------------------------------------------ INFO
# [bin/extractor.sh]
# author        : Pascal Malouin @https://github.com/alterEGO-Linux
# created       : 2023-08-01 19:55:12 UTC
# updated       : 2025-12-22 12:53:57 UTC
# description   : Compressed files universal extractor.

set -eu

BLUE=$'\033[34m'
RED=$'\033[31m'
RESET=$'\033[0m'

check_applications() {

    local app
    local apps=("$@")
    local missing=()

    for app in "${apps[@]}"; do
        if ! command -v "${app}" > /dev/null 2>&1; then
            missing+=("${app}")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        printf '%s\n' "${RED}[!]${RESET} Missing application(s): ${missing[*]}."
        return 1
    fi
}

usage() {
    cat <<EOF
================================================================================
[+] extractor - Compressed files universal extractor.
================================================================================
Usage:
  extractor <file1> [file2 ... fileN]

This script extracts compressed files based on their extension.

Supported formats:

  --- ( Tar archives )
  *.tar        - Extracts an uncompressed tar archive.
  *.tar.gz     - Extracts a gzip-compressed tar archive.
  *.tgz        - Alias for *.tar.gz.
  *.tar.bz2    - Extracts a bzip2-compressed tar archive.
  *.tbz2       - Alias for *.tar.bz2.
  *.tar.xz     - Extracts an xz-compressed tar archive.
  *.txz        - Alias for *.tar.xz.
  *.tar.zst    - Extracts a zstd-compressed tar archive.
  *.tzst       - Alias for *.tar.zst.

  --- ( Single-file compression )
  *.gz         - Decompresses a gzip-compressed file.
  *.bz2        - Decompresses a bzip2-compressed file.
  *.xz         - Decompresses an xz-compressed file.
  *.lzma       - Decompresses an lzma-compressed file.
  *.Z          - Decompresses a legacy UNIX compress file.

  --- ( Other archive formats )
  *.zip        - Extracts a ZIP archive.
  *.rar        - Extracts a RAR archive.
  *.7z         - Extracts a 7z archive.
  *.iso        - Extracts files from an ISO image.
  *.cpio       - Extracts a cpio archive.

Notes:
- Tar archives and multi-file archives are extracted into a child directory
  named after the compressed file.
- Single-file compression formats (*.gz, *.bz2, *.xz, *.lzma, *.Z) extract
  directly in place.
- ISO images are extracted using 7z (no mounting required).

================================================================================
EOF
}

# --- show help if no arguments.
if [[ "$#" -eq 0 ]]; then
    usage
    exit 0
fi

# --- show help and ignore other arguments.
for arg in "$@"; do
    if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        usage
        exit 0
    fi
done

for file in "$@"; do
    if [ -f "$file" ]; then

        # --- convert filename into a proper extraction directory
        filename=$(basename "$file")
        directory="$(dirname $file)/${filename//./-}-uncompressed"

        case "$file" in
            # ---- tar archives (ordered: most specific first)
            *.tar.gz|*.tgz)
                check_applications tar || exit 1
                mkdir -p "$directory"
                tar xzf -- "$file" -C "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.tar.bz2|*.tbz2)
                check_applications tar || exit 1
                mkdir -p "$directory"
                tar xjf -- "$file" -C "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.tar.xz|*.txz)
                check_applications tar || exit 1
                mkdir -p "$directory"
                tar xJf -- "$file" -C "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.tar.zst|*.tzst)
                check_applications tar || exit 1
                mkdir -p "$directory"
                tar --zstd -xf -- "$file" -C "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.tar)
                check_applications tar || exit 1
                mkdir -p "$directory"
                tar xf -- "$file" -C "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;

            # ---- single-file compressions
            *.gz)
                check_applications gunzip || exit 1
                gunzip -- "$file"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.bz2)
                check_applications bunzip2 || exit 1
                bunzip2 -- "$file"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.xz)
                check_applications unxz || exit 1
                unxz -- "$file"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.lzma)
                check_applications unlzma || exit 1
                unlzma -- "$file"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.Z)
                check_applications uncompress || exit 1
                uncompress -- "$file"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;

            # ---- other archive formats
            *.zip)
                check_applications unzip || exit 1
                mkdir -p "$directory"
                unzip -- "$file" -d "$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.rar)
                check_applications unrar || exit 1
                mkdir -p "$directory"
                unrar x -- "$file" "$directory/"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.7z)
                check_applications 7z || exit 1
                mkdir -p "$directory"
                7z x -- "$file" -o"$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted.\n" "$file"
                ;;
            *.iso)
                check_applications 7z || exit 1
                mkdir -p "$directory"
                7z x -- "$file" -o"$directory"
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted (ISO image).\n" "$file"
                ;;
            *.cpio)
                check_applications cpio || exit 1
                mkdir -p "$directory"
                ( cd "$directory" && cpio -id < "$file" )
                printf "${BLUE}[-]${RESET} extractor: '%s' extracted (cpio archive).\n" "$file"
                ;;

            # ---- fallback
            *)
                printf '%s\n' "${RED}[!]${RESET} extractor: '$file' - unknown archive method."
                ;;
        esac
    else
        printf "${RED}[!]${RESET} extractor: '$file' is not a valid file."
    fi
done
