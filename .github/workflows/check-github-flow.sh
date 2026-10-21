#!/bin/bash

set -euo pipefail

HEAD_BRANCH=${1:-}
BASE_BRANCH=${2:-}

echo "Head branch: ${HEAD_BRANCH}, Base branch: ${BASE_BRANCH}"

# GitHub Flow branches must target main.
if [[ "${BASE_BRANCH}" != "main" ]]; then
  echo "Error: Pull requests must target the main branch."
  exit 1
fi

# Allow both human-created feature branches and Codex-created branches.
case "${HEAD_BRANCH}" in
  feature/* | codex/*)
    ;;
  *)
    echo "Error: Head branch must start with feature/ or codex/."
    exit 1
    ;;
esac

echo "Branch name convention is valid."
