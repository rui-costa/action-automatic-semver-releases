#!/bin/sh

source '/src/functions.sh'

main()
{
  local semver="$1"
  local branch="$2"
  local format="$3"
  local token="$4"
  local releaseNotes="$7"
  local label="$6"

  init $branch

  local current_version=$( get_current_version )
  echo $current_version
  local next_version=$( get_full_version "$current_version" "$semver" "$label" )

  local changelog=$( get_release_body "$format" "$releaseNotes" "$next_version" "$current_version" )
  post_release "https://api.github.com/repos/$GITHUB_REPOSITORY/releases" "$token" "$changelog" 
}

main "$1" "$2" "$3" "$4" "$5" "$6"
