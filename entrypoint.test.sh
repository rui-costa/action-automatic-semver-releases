#!/bin/sh

source 'src/test.sh'
source 'src/functions.sh'

testVersion="1.5.9"
label="final"
currentVersion=`git tag | tail -1`
releaseNotes="No line to output on changelog"

# Test the Major version
assertEqual 'Is major version to get incremented to 2' $( get_major_version $testVersion "MAJOR" ) 2
assertEqual 'Is major version not get incremented on MINOR' $( get_major_version $testVersion "MINOR" ) 1
assertEqual 'Is major version not get incremented on PATCH' $( get_major_version $testVersion "PATCH" ) 1

# Test the Minor version
assertEqual 'Is minor version is SET to 0 on MAJOR' $( get_minor_version $testVersion "MAJOR" ) 0
assertEqual 'Is major version to get incremented to 4' $( get_minor_version $testVersion "MINOR" ) 6
assertEqual 'Is major version not get incremented on PATCH' $( get_minor_version $testVersion "PATCH" ) 5

# Test the Patch version
assertEqual 'Is patch version SET to 0 on MAJOR' $( get_patch_version $testVersion "MAJOR" ) 0
assertEqual 'Is minor version is SET to 0 on MINOR' $( get_patch_version $testVersion "MINOR" ) 0
assertEqual 'Is major version to get incremented to 7' $( get_patch_version $testVersion "PATCH" ) 10

# Test the label
assertEqual 'When label is provided, -label is retrned' $( get_label $label ) "-final"
assertEqual 'When label is not provided, empty is retrned' $( get_label "" ) ''

# Test full version concatenation
assertEqual 'When incrementing Major, new version will be 2.0.0' $( get_full_version $testVersion "MAJOR" "" ) "2.0.0"
assertEqual 'When incrementing Minor, new version will be 1.6.0' $( get_full_version $testVersion "MINOR" "" ) "1.6.0"
assertEqual 'When incrementing Patch, new version will be 1.5.10' $( get_full_version $testVersion "PATCH" "" ) "1.5.10"
assertEqual 'When adding label to MAJOR, new version will be 2.0.0-final' $( get_full_version $testVersion "MAJOR" $label ) "2.0.0-final"

assertEqual 'Returns current version' $( get_current_version ) $currentVersion

expectation='{ "tag_name": "'$testVersion'", "body": "'$releaseNotes'" }'
assertEqual 'When releaseNotes are provided, releaseNotes are returned' "$( get_release_body "$releaseNotes" "$testVersion" "$currentVersion" )" "$expectation"
assertNotEqual 'When releaseNotes are provided, releaseNotes are returned' "$( get_release_body "" "$testVersion" "$currentVersion" )" "$expectation"

gitNotes=$( git rev-list --oneline $currentVersion.. . | awk '{ printf "%s\\n", $0 }')
expectation='{ "tag_name": "'$testVersion'", "body": "### Changelog\n\n'$gitNotes'" }'
assertEqual 'Correct output format for releaseNotes' "$( get_release_body "" "$testVersion" "$currentVersion" )" "$expectation"

report