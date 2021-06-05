#!/bin/sh

. 'src/test.sh'
. 'src/functions.sh'

testVersion="1.5.9"
label="final"
currentVersion=`git tag | tail -1`
releaseNotes="No line to output on changelog"

# Test the Major version
assertEqual 'MAJOR version to get incremented to 2' $( get_major_version $testVersion "MAJOR" ) 2
assertEqual 'MAJOR version not get incremented on MINOR' $( get_major_version $testVersion "MINOR" ) 1
assertEqual 'MAJOR version not get incremented on PATCH' $( get_major_version $testVersion "PATCH" ) 1
assertEqual 'MAJOR version should be 1 when no version is exists - semver MAJOR' $( get_major_version "" "MAJOR" ) 1
assertEqual 'MAJOR version should be 0 when no version is exists - semver MINOR' $( get_major_version "" "MINOR" ) 1
assertEqual 'MAJOR version should be 0 when no version is exists - semver PATCH' $( get_major_version "" "PATCH" ) 1

# Test the Minor version
assertEqual 'MINOR version is SET to 0 on MAJOR' $( get_minor_version $testVersion "MAJOR" ) 0
assertEqual 'MINOR version to get incremented to 4' $( get_minor_version $testVersion "MINOR" ) 6
assertEqual 'MINOR version not get incremented on PATCH' $( get_minor_version $testVersion "PATCH" ) 5
assertEqual 'MINOR version should be 0 when no version is exists - semver MAJOR' $( get_minor_version "" "MAJOR" ) 0
assertEqual 'MINOR version should be 0 when no version is exists - semver MINOR' $( get_minor_version "" "MINOR" ) 0
assertEqual 'MINOR version should be 0 when no version is exists - semver PATCH' $( get_minor_version "" "PATCH" ) 0

# Test the Patch version
assertEqual 'PATCH version SET to 0 on MAJOR' $( get_patch_version $testVersion "MAJOR" ) 0
assertEqual 'PATCH version is SET to 0 on MINOR' $( get_patch_version $testVersion "MINOR" ) 0
assertEqual 'PATCH version to get incremented to 7' $( get_patch_version $testVersion "PATCH" ) 10
assertEqual 'PATCH version should be 0 when no version is exists - semver MAJOR' $( get_patch_version "" "MAJOR" ) 0
assertEqual 'PATCH version should be 0 when no version is exists - semver MINOR' $( get_patch_version "" "MINOR" ) 0
assertEqual 'PATCH version should be 0 when no version is exists - semver PATCH' $( get_patch_version "" "PATCH" ) 0

# Test the label
assertEqual 'When label is provided, -label is retrned' $( get_label $label ) "-final"
assertEqual 'When label is not provided, empty is retrned' $( get_label "" ) ''

# Test full version concatenation
assertEqual 'When incrementing Major, new version will be 2.0.0' $( get_full_version $testVersion "MAJOR" "" ) "2.0.0"
assertEqual 'When incrementing Minor, new version will be 1.6.0' $( get_full_version $testVersion "MINOR" "" ) "1.6.0"
assertEqual 'When incrementing Patch, new version will be 1.5.10' $( get_full_version $testVersion "PATCH" "" ) "1.5.10"
assertEqual 'Version should be 1.0.0 when no version exists - semver MAJOR' $( get_full_version "" "MAJOR" "" ) "1.0.0"
assertEqual 'Version should be 1.0.0 when no version exists - semver MINOR' $( get_full_version "" "MINOR" "" ) "1.0.0"
assertEqual 'Version should be 1.0.0 when no version exists - semver PATCH' $( get_full_version "" "PATCH" "" ) "1.0.0"
assertEqual 'When adding label to MAJOR, new version will be 2.0.0-final' $( get_full_version $testVersion "MAJOR" $label ) "2.0.0-final"

assertEqual 'Returns current version' $( get_current_version ) $currentVersion

expectation='{ "tag_name": "'$testVersion'", "body": "'$releaseNotes'" }'
assertEqual 'When releaseNotes are provided, releaseNotes are returned' "$( get_release_body "$releaseNotes" "$testVersion" "$currentVersion" )" "$expectation"
assertNotEqual 'When are not provided, releaseNotes are not returned' "$( get_release_body "" "$testVersion" "$currentVersion" )" "$expectation"

gitNotes=$( git log --oneline $currentVersion.. . | awk '{ printf "%s\\n", $0 }')
expectation='{ "tag_name": "'$testVersion'", "body": "### Changelog\n\n'$gitNotes'" }'
assertEqual 'Correct output format for releaseNotes' "$( get_release_body "" "$testVersion" "$currentVersion" )" "$expectation"

gitNotes=$( git log --oneline | awk '{ printf "%s\\n", $0 }')
expectation='{ "tag_name": "1.0.0", "body": "### Changelog\n\n'$gitNotes'" }'
assertEqual 'Correct output format for releaseNotes for 1st version' "$( get_release_body "" "1.0.0" "" )" "$expectation"


report