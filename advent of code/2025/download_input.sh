#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 || ! $1 =~ ^([1-9]|1[0-9]|2[0-5])$ ]]; then
  echo "Usage: $0 DAY (1-25)" >&2
  exit 1
fi

day=$1
year=2025
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cookie_file="$repo_dir/.cookie"
output_file="$repo_dir/inputs/input_${day}.txt"

if [[ ! -f $cookie_file ]]; then
  echo "Missing cookie file: $cookie_file" >&2
  exit 1
fi

if [[ -e $output_file ]]; then
  echo "Refusing to overwrite existing file: $output_file" >&2
  exit 1
fi

mkdir -p -- "$repo_dir/inputs"

session=$(<"$cookie_file")
session=${session#session=}

if [[ -z $session ]]; then
  echo "Cookie file is empty: $cookie_file" >&2
  exit 1
fi

curl --fail --silent --show-error --location \
  --cookie "session=$session" \
  --user-agent "${AOC_USER_AGENT:-personal Advent of Code input downloader}" \
  "https://adventofcode.com/$year/day/$day/input" \
  --output "$output_file"

echo "Downloaded inputs/input_${day}.txt"
