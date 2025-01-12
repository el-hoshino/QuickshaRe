#!/bin/bash

# Get the head branch name
HEAD_BRANCH=$(echo "$1" | awk -F/ '{print $1}')

# Get the base branch name
BASE_BRANCH=$(echo "$2" | awk -F/ '{print $1}')

# Get the test flag
TEST_FLAG=$(echo "$3" | awk -F/ '{print $1}')

echo "Head branch: ${HEAD_BRANCH}, Base branch: ${BASE_BRANCH}"

# Check if head branch is feature branch and base branch is develop
if [[ "${HEAD_BRANCH}" == "feature" ]]; then
  if [ "${BASE_BRANCH}" != "develop" ]; then
    echo "Error: A feature branch can only be merged into the develop branch."
    exit 1
  fi

# Check if head branch is release branch and base branch is develop or main
elif [[ "${HEAD_BRANCH}" == "release" ]]; then
  if [ "${BASE_BRANCH}" != "develop" ] && [ "${BASE_BRANCH}" != "main" ]; then
    echo "Error: A release branch can only be merged into the develop or main branch."
    exit 1
  fi

# Check if head branch is hotfix branch and base branch is develop or main
elif [[ "${HEAD_BRANCH}" == "hotfix" ]]; then
  if [ "${BASE_BRANCH}" != "develop" ] && [ "${BASE_BRANCH}" != "main" ]; then
    echo "Error: A hotfix branch can only be merged into the develop or main branch."
    exit 1
  fi

else
  echo "Error: Head branch must be a feature, release, or hotfix branch."
  exit 1
fi

# Check if test flag exist
if [ -z "${TEST_FLAG}" ]; then
  # Check if pull request to develop branch and main branch have been opened for release or hotfix branch when test flag is not set
  if [[ "${HEAD_BRANCH}" == "release" ]] || [[ "${HEAD_BRANCH}" == "hotfix" ]]; then
    # Check if pull request to develop branch exists
    if ! git ls-remote --exit-code origin "refs/pull/*/head:refs/heads/develop"; then
      echo "Error: No pull request to develop branch exists for ${HEAD_BRANCH} branch."
      exit 1
    fi
    # Check if pull request to main branch exists
    if ! git ls-remote --exit-code origin "refs/pull/*/head:refs/heads/main"; then
      echo "Error: No pull request to main branch exists for ${HEAD_BRANCH} branch."
      exit 1
    fi
  fi
fi

# Check if release branch has all issues completed
if [[ "${HEAD_BRANCH}" == "release" ]]; then
  echo "Pleass check if all issues for the release have been completed."
fi

echo "Branch name convention is valid."