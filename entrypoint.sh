#!/bin/sh

source '/src/functions.sh'

main()
{
  local semver="$1"
  local token="$2"
  local releaseNotes="$3"
  local label="$4"

  init

  local current_version=$( get_current_version )
  local next_version=$( get_full_version "$current_version" "$semver" "$label" )

  local changelog=$( get_release_body "$releaseNotes" "$next_version" "$current_version" )
  echo $changelog
  post_release "https://api.github.com/repos/$GITHUB_REPOSITORY/releases" "$token" "$changelog" 
}

main "$1" "$2" "$3" "$4"
