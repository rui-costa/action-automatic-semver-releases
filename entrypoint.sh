#!/bin/sh -l

SEM_VER="$1"
LABEL="$2"
MAIN_BRANCH="$3"
CHANGELOG_FORMAT="$4"
GITHUB_TOKEN="$5"

# FAIL for invalid version inputs
if(( '$SEM_VER' != 'MAJOR' & '$SEM_VER' != 'MINOR' & '$SEM_VER' != 'PATCH' ))
then
  echo "ERROR: INVALID VERSION INPUT"
  echo "The version $SEM_VER is not a valid value."
  echo "The value is case sensitive. Make sure you type it correctly."
  echo "Version value MUST be either MAJOR, MINOR or PATCH."
  exit 1
fi

CHANGELOG_FORMAT=`echo $CHANGELOG_FORMAT | sed 's|<<GITHUB_REPOSITORY>>|$GITHUB_REPOSITORY|g'`

# Get the latest tag and add it to a output variable
git fetch origin $MAIN_BRANCH
git fetch --tags
git rebase origin/$MAIN_BRANCH
LATEST=`git tag | tail -1`

# Generating semantic versioning. Following https://semver.org/
# MAJOR version when you make incompatible API changes
# Major version X (X.y.z | X > 0) MUST be incremented if any backwards incompatible changes are introduced to the public API

if(( '$SEM_VER' == 'MAJOR' ))
then
MAJOR=`git tag | tail -1 | cut -d '.' -f 1 | awk '{$1=$1+1;1'`
else
MAJOR=`git tag | tail -1 | cut -d '.' -f 1`
fi

# MINOR version when you add functionality in a backwards compatible manner
# Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards compatible functionality is introduced to the public API.
# It MUST be incremented if any public API functionality is marked as deprecated.
if(( '$SEM_VER' == 'MAJOR' ))
then
  MINOR=`git tag | tail -1 | cut -d '.' -f 2 | awk '{$1=$1+1;1'`
else
  MINOR=`git tag | tail -1 | cut -d '.' -f 2`
fi

# PATCH version when you make backwards compatible bug fixes.
# Patch version Z (x.y.Z | x > 0) MUST be incremented if only backwards compatible bug fixes are introduced. A bug fix is defined as an internal change that fixes incorrect behavior.
if(( '$SEM_VER' == 'PATCH' ))
then
  PATCH=`git tag | tail -1 | cut -d '.' -f 3 | awk '{$1=$1+1;1'`
else
  PATCH=`git tag | tail -1 | cut -d '.' -f 3`
fi


# Minor version MUST be reset to 0 when major version is incremented.
if(( '$SEM_VER' == 'MAJOR' ))
then
  MINOR='0'
fi

# Patch version MUST be reset to 0 when major version is incremented.
# Patch version MUST be reset to 0 when minor version is incremented.
if(( '$SEM_VER' == 'MAJOR' || '$SEM_VER' == 'MINOR' ))
then
  PATCH='0'
fi

# Add label if exists
if(( '$LABEL' != '' ))
then
PATCH=$PATCH-$LABEL
fi

# Create final form of semantic version
# MAJOR.MINOR.PATCH
VERSION=$MAJOR.$MINOR.$PATCH

# Generate the Changelog Text
echo "{ \'tag_name\': \'$VERSION\', \'body\': \' ### Changelog\n\n" > data
git log --all --pretty='$CHANGELOG_FORMAT' $LATEST .. . | sed 's|*|-|g' >> data
echo "\'" >> data

cat data

# Create release using github API
# https://docs.github.com/en/rest/reference/repos#create-a-release
curl \
-X POST \
-H "Accept: application/vnd.github.v3+json" \
-H "Authorization: Bearer $GITHUB_TOKEN" \
https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
-d @data
