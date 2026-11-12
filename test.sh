#!/usr/bin/env bash
# Runs the weather Model.js unit tests. qmllint is not installed on this VM,
# so QML is checked by the brace/paren/bracket balance script, not here.
set -euo pipefail
cd "$(dirname "$0")"
node --test tests/*.test.js
