#!/bin/bash

# Get the head branch name
HEAD_BRANCH=$(echo "$1" | awk -F/ '{print $1}')

# Get the base branch name
BASE_BRANCH=$(echo "$2" | awk -F/ '{print $1}')

echo "Head branch: ${HEAD_BRANCH}, Base branch: ${BASE_BRANCH}"

# Check if head branch is feature branch and base branch is develop
if [[ "${HEAD_BRANCH}" == "feature" ]]; then
  if [ "${BASE_BRANCH}" != "main" ]; then
    echo "Error: A feature branch can only be merged into the main branch."
    exit 1
  fi

else
  echo "Error: Head branch must be a feature branch."
  exit 1
fi

echo "Branch name convention is valid."
