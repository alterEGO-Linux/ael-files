#!/usr/bin/env bash
# ------------------------------------------------------------------------ INFO
# [/.ael/bin/getmp3.sh]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2023-08-02 00:36:18 UTC
# updated       : 2026-04-09 11:37:40 UTC
# description   : Extracting audio (.mp3) from video.

getmp3() {

    local __arg
    local __artist
    local __artist_safe
    local __title
    local __title_safe
    local __url
    local __blue=$'\033[34m'
    local __red=$'\033[31m'
    local __reset=$'\033[0m'

    trap 'unset -f usage check_applications; trap - RETURN' RETURN

    check_applications() {
      local __app
      for __app in "${@}"; do
          if ! command -v $__app >/dev/null 2>&1; then
              printf '%s\n' "${__red}[!]${__reset} ${__app} is not installed."
              return 1
          fi
      done
    }
    check_applications ffmpeg find grep head tr yt-dlp || return 1

    usage() {
        cat <<EOF
================================================================================
[+] getmp3 - Extracting audio (.mp3) from video.
================================================================================
Usage:
  getmp3 "Artist|Title" <YouTube-URL>

Arguments:
  "Artist|Title"    The artist and title, separated by a '|'.
  <YouTube-URL>     The valid YouTube video URL.

Examples:
  getmp3 "Azu|Evolution Of Memes" "https://www.youtube.com/watch?v=DpwwR-jlQX8"

Options:
  -h, --help        Show this help message and exit.
================================================================================
EOF
    }

    # --| Help.
    for __arg in "${@}"; do
        if [ "${__arg}" == '-h' ] || [ "${__arg}" == '--help' ]; then
            usage
            return 0
        fi
    done

    # --| Error - too many arguments
    if [ $# -gt 2 ]; then
        usage
        echo
        printf '%s\n' "${__red}[!]${__reset} Too many arguments."
        return 1
    fi

    for __arg in "${@}"; do
        if echo "${__arg}" | grep -q "|"; then
            IFS="|" read -r __artist __title <<< "${__arg}"
            __artist_safe=$(echo "${__artist}" | tr ' ' '_')
            __title_safe=$(echo "${__title}" | tr ' ' '_')
        elif echo "${__arg}" | grep -qE "^https?://"; then
            __url="${__arg}"
        else
            usage
            echo
            printf '%s\n' "${__red}[!]${__reset} Unknown argument: ${__arg}."
            return 1
        fi
    done

    # --| Error - missing value
    if [ -z "${__artist_safe}" ]; then
        usage
        echo
        printf '%s\n' "${__red}[!]${__reset} Missing artist's value."
        return 1
    fi

    if [ -z "${__title_safe}" ]; then
        usage
        echo
        printf '%s\n' "${__red}[!]${__reset} Missing title's value."
        return 1
    fi

    if [ -z "${__url}" ]; then
        usage
        echo
        printf '%s\n' "${__red}[!]${__reset} Missing URL's value."
        return 1
    fi

    printf '%s\n' "${__blue}[+]${__reset} getmp3 - Starting process of extraction."
    command yt-dlp -f "bestaudio" \
                   --extract-audio \
                   --audio-format mp3 \
                   --audio-quality 0 \
                   --prefer-ffmpeg \
                   --output "${__artist_safe}-${__title_safe}-%(id)s" \
                  "${__url}"

    local __filename=$(basename "$(find . -maxdepth 1 -type f -name "${__artist_safe}-${__title_safe}-*.mp3" | head -n 1)")
    local __tagged="tagged-${__filename}"

    if [ ! -f "${__filename}" ]; then
        printf '%s\n' "${__red}[!]${__reset} MP3 file not found."
        return 1
    fi

    printf '%s\n' "${__blue}[*]${__reset} Tagging metadata..."
    ffmpeg -y -i "${__filename}" \
        -metadata artist="${__artist}" \
        -metadata title="${__title}" \
        -metadata comments="${__url}" \
        -id3v2_version 3 \
        -write_id3v1 1 \
        -b:a 320k \
        "${__tagged}" >/dev/null 2>&1

    mv "${__tagged}" "${__filename}"

    printf '%s\n' "${__blue}[*]${__reset} Extraction done: ${__filename}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    getmp3 "$@"
fi
