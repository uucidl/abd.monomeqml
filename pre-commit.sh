#!/usr/bin/env sh

function die() {
    msg=$1
    printf "%s\n" "$msg" >&2
    exit 1
}

CLANG_FORMAT=${CLANG_FORMAT:-$(which clang-format)}
[ -x "${CLANG_FORMAT}" ] || die "missing CLANG_FORMAT env variable"

find src \( -name "*.cpp" -o -name "*.hpp" -o -name "*.js" \) -print | while read f; do
                                                           "${CLANG_FORMAT}" -i "${f}"
                                                       done
