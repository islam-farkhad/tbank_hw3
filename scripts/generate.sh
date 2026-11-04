#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_root"
PATH="$project_root/.bin:$PATH"
export PATH

check_version() {
  if ! actual=$("$1" --version 2>/dev/null); then
    printf 'Не найден %s. Установите protoc 29.3 и выполните make tools.\n' "$1" >&2
    exit 1
  fi
  if [ "$actual" != "$2" ]; then
    printf 'Ожидалось: %s; установлено: %s. См. README.md.\n' "$2" "$actual" >&2
    exit 1
  fi
}

check_version protoc 'libprotoc 29.3'
check_version protoc-gen-go 'protoc-gen-go v1.34.2'
check_version protoc-gen-go-grpc 'protoc-gen-go-grpc 1.5.1'

output_dir=.
case "${1:-}" in
  '') ;;
  --check)
    output_dir=$(mktemp -d)
    trap 'rm -rf "$output_dir"' EXIT HUP INT TERM
    ;;
  *) printf 'Usage: sh scripts/generate.sh [--check]\n' >&2; exit 2 ;;
esac

protoc --fatal_warnings --proto_path=proto --proto_path=third_party \
  --go_out="$output_dir" --go_opt=module=flight-booking-proto \
  --go-grpc_out="$output_dir" --go-grpc_opt=module=flight-booking-proto \
  proto/flight/v1/flight.proto

if [ "$output_dir" != . ]; then
  diff -ru gen "$output_dir/gen"
  printf 'Сгенерированные файлы соответствуют .proto.\n'
fi
