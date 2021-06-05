#!/bin/sh

# FAIL for invalid version inputs
validate()
{
  local increment=$1

  if [ $increment = 'MAJOR' ] || [ $increment = 'MINOR' ] || [ $increment = 'PATCH' ]
  then
    echo "VALID SEMANTIC VERSION INCREMENT"
  else
    echo "ERROR: INVALID VERSION INPUT"
    echo "The version $increment is not a valid value."
    echo "The value is case sensitive. Make sure you type it correctly."
    echo "Version value MUST be either MAJOR, MINOR or PATCH."
    exit 1
  fi
}

# Get the latest tag and add it to a output variable
init()
{
  git fetch --unshallow
}

get_current_version()
{
  local output=`git tag | tail -1`
  echo "$output"
}

# Generating semantic versioning. Following https://semver.org/
# MAJOR version when you make incompatible API changes
# Major version X (X.y.z | X > 0) MUST be incremented if any backwards incompatible changes are introduced to the public API
get_major_version()
{
  local current_version="$1"
  local increment="$2"
  local output="0"
  
  if [ $increment = 'MAJOR' ]
  then
    output=`echo $current_version | cut -d '.' -f 1 | awk '{$1=$1+1};1'`
  else
    output=`echo $current_version | cut -d '.' -f 1`
  fi

  echo "$output"
}


# MINOR version when you add functionality in a backwards compatible manner
# Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards compatible functionality is introduced to the public API.
# It MUST be incremented if any public API functionality is marked as deprecated.
# Minor version MUST be reset to 0 when major version is incremented.
get_minor_version()
{
  local current_version="$1"
  local increment="$2"
  local output="0"

  if ! [ $increment = 'MAJOR' ]
  then
    if [ $increment = 'MINOR' ]
    then
      output=`echo $current_version | cut -d '.' -f 2 | awk '{$1=$1+1};1'`
    else
      output=`echo $current_version | cut -d '.' -f 2`
    fi
  fi

  echo "$output"
}

# PATCH version when you make backwards compatible bug fixes.
# Patch version Z (x.y.Z | x > 0) MUST be incremented if only backwards compatible bug fixes are introduced. A bug fix is defined as an internal change that fixes incorrect behavior.
# Patch version MUST be reset to 0 when major version is incremented.
# Patch version MUST be reset to 0 when minor version is incremented.
get_patch_version()
{
  local current_version="$1"
  local increment="$2"
  local output="0"

  if ! [ $increment = 'MAJOR' ] && ! [ $increment = 'MINOR' ]
  then
    output=`echo $current_version | cut -d '.' -f 3 | cut -d '-' -f 1 | awk '{$1=$1+1};1'`
  fi

  echo "$output"
}

# Add label if exists
get_label()
{
  local label=$1
  local output=""

  if ! [ "$label" = '' ]
  then
    output=-$label
  else
    output=''
  fi

  echo "$output"
}

# Create final form of semantic version
# MAJOR.MINOR.PATCH
get_full_version()
{
  local major="$( get_major_version "$1" "$2")"
  local minor="$( get_minor_version "$1" "$2")"
  local patch="$( get_patch_version "$1" "$2")"
  local label="$( get_label "$3")"
  local output="$major.$minor.$patch$label"
  echo "$output"
}

get_release_body()
{
  local releaseNotes="$1"
  local next_version="$2"
  local current_version="$3"
  local output='{ "tag_name": "'$next_version'", "body": "'

  if [ "$releaseNotes" = "" ]
  then
    gitNotes=`git log --all --oneline $current_version.. . | awk '{ printf "%s \\n ", $0 }'`
    output=$output"### Changelog\n\n"$gitNotes    
  else
    output=$output$releaseNotes
  fi
  output=$output'" }'

  echo "$output"
}

post_release()
{
  local url=$1
  local token=$2
  local changelog=$3
  
  # create data file 
  echo $changelog > data

  # Create release using github API
  # https://docs.github.com/en/rest/reference/repos#create-a-release
  curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer $token" \
  $url \
  -d @data

}
