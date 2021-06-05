#!/bin/sh

# SET COLOR FOR ECHO
ColorRed='\033[0;31m'
ColorGreen='\033[0;32m'
NoColor='\033[0m'

failedTests=0
succeedTests=0
errorLog=""

assertEqual()
{
    local test_name="$1"
    local returned="$2"
    local expectation="$3"

    if [ "$returned" = "$expectation" ]
    then
        succeedTests=`echo $succeedTests | awk '{$1=$1+1};1'`
    else
        errorLog=$errorLog"❌ Equal Test: "$test_name"\n"
        errorLog=$errorLog"Both values MUST be Equal\n"
        errorLog=$errorLog"Expected: "$expectation"\n"
        errorLog=$errorLog"Got: "$ColorRed$returned$NoColor"\n\n"
        failedTests=`echo $failedTests | awk '{$1=$1+1};1'`
    fi
}

assertNotEqual()
{
    local test_name="$1"
    local returned="$2"
    local expectation="$3"

    if ! [ "$returned" = "$expectation" ]
    then
        succeedTests=`echo $succeedTests | awk '{$1=$1+1};1'`
    else
        errorLog=$errorLog"❌ Test: "$test_name"\n"
        errorLog=$errorLog"Both values CANNOT be Equal\n"
        errorLog=$errorLog"Doesn't Expected: "$expectation"\n"
        errorLog=$errorLog"Got: "$ColorRed$returned$NoColor"\n\n"
        failedTests=`echo $failedTests | awk '{$1=$1+1};1'`
    fi
}

report(){

    local totalTests=$((succeedTests+failedTests))
    local ColorToUse=$NoColor

    if ! [ "$errorLog" = "" ]
    then
        echo -e $errorLog
    fi

    if ! [ $failedTests -eq 0 ]
    then
        ColorToUse=$ColorRed
    else
        ColorToUse=$ColorGreen
    fi

    echo -e "Tests:\t"$ColorToUse$succeedTests" passed"$NoColor", "$totalTests" total"

    if ! [ $failedTests -eq 0 ]
    then
        exit 1
    fi

}