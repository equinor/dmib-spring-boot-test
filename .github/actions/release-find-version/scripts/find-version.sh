#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error and exit immediately.
# Return the exit status of the last command in the pipe that failed.
set -euo pipefail

# Function to find and extract a version number from a given input string.
#
# This function uses a regular expression to match version numbers in the format of "X.Y.Z" where X, Y, and Z are digits.
# The version number is expected to be part of a branch name that starts with either "hotfix" or "release".
#
# Parameters:
#   input_text (string): The input string from which to extract the version number.
#
# Outputs:
#   If a version number is found, it is stored in the VERSION environment variable.
#   If running in a GitHub Actions environment, the version number is also added to the GITHUB_OUTPUT environment variable.
#
# Returns:
#   0 (true) if a version number is found and stored in the VERSION environment variable.
#   1 (false) if no version number is found in the input string.
#
# Example:
#   if find_version_number "release/v1.0.0"; then
#       echo "Version: $VERSION"
#   else
#       echo "Unable to find version"
#   fi
#
function find_version_number() {
    local input_text="$1"
    echo ":: Given input string: '$input_text'"

    # use bash regex matching
    if [[ "$input_text" =~ .*(hotfix|release)\/v?([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
        # if found, store the version in an environment variable.
        # in our regex, we have two match groups: the first one is the branch type, second is the version number.
        # BASH_REMATCH is an array that contains the match groups after matching ([0] is the entire string 1,2.. etc are the match groups).
        # Take the second match group, thus [2].
        VERSION="${BASH_REMATCH[2]}"
        echo ":: Found version: '$VERSION'"

        # when running this script in github actions, we can set an output variable that can be used in the next steps.
        if [ -n "${GITHUB_OUTPUT:-}" ]; then
            echo "VERSION=$VERSION" >> "$GITHUB_OUTPUT"
            echo ":: Added version to GITHUB_OUTPUT"
        fi

        return 0 # true
    else
        echo ":: Unable to find version in given string: '$input_text'"

        if [ -n "${GITHUB_OUTPUT:-}" ]; then
            echo "VERSION=" >> "$GITHUB_OUTPUT"
            echo ":: Empty version added to GITHUB_OUTPUT"
        fi

        return 1 # false
    fi
}

echo "Running script to determine version number..."

# check if the branch name contains the version number
# it is usually the case when creating a release PR
echo "Using branch name as input (release PR scenario)"

if find_version_number "${GITHUB_HEAD_REF:-}"; then
    exit 0 # true, successfully found version
fi

# check if the commit message contains the version number
# it is usually the case when merging a release PR to main branch
echo "Using commit message to determine version (ready to publish scenario)"
last_commit_message=$(git log -1 --oneline)

if find_version_number "$last_commit_message"; then
    exit 0 # true, successfully found version
fi

# if we reach here, we were unable to find the version number
echo "Unable to determine version number, exiting... ¯\_(ツ)_/¯"
exit 1 # false, unable to find version
