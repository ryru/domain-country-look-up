#!/bin/bash -u

###############################################################################
# Author  : Pascal K. (pascal@addere.ch)
# Date    : 20160830
# Project : Domain Country Look-up
# Purpose : Contains basic functionality handle json data.
# License : BSD 3-Clause License (see License.txt)
###############################################################################

############################################################################### 
# Static variables - edit if necessary
###############################################################################

# Localisation information 
MY_LANGUAGE="de"
MY_COUNTRY_NAME="Schweiz"     # change country name based on MY_LANGUAGE config
MY_COUNTRY_CODE="CH"          # change country code based on MY_LANGUAGE config


# Linux utility configuration
CURL='/usr/bin/curl -s'
WC='/usr/bin/wc'
SLEEP='/bin/sleep'            # only used for throttling

# Url Api
URI_BASE='http://ip-api.com/json/'
URI_DOMAIN=""
URI_LANGUAGE="?lang=$MY_LANGUAGE"

# Query properties
MAX_QUERY_PER_MINUTE=150


############################################################################### 
# Script - do not edit the script below
###############################################################################

# load json helper functions
source 'lib/json-helper.sh'

INPUT_FILE=$1

# check if passed argument is a valid file
if [[ -d $INPUT_FILE ]]; then
    echo "ERROR $INPUT_FILE is a directory"
    exit 1
elif [[ -f $INPUT_FILE ]]; then
    # file seems to be fine
    echo ""
else
    echo "ERROR invalid argument: $INPUT_FILE"
    exit 1
fi

# count lines in file
NUM_OF_LINES=$($WC -l < "$INPUT_FILE")

# throttle request if file entries exceed MAX_QUERY_PER_MINUTE
THROTTLE=false
if [ $NUM_OF_LINES -gt $MAX_QUERY_PER_MINUTE ]; then
    THROTTLE=true
fi

# print start msg
echo "Processing $INPUT_FILE ($NUM_OF_LINES entries)"
if [ "$THROTTLE" = true ] ; then
    echo "$INPUT_FILE contains more than maximum request/minute limit ($MAX_QUERY_PER_MINUTE) activate throttling"
fi
    


OUTPUT_COUNTER=0              # increments the outputted lines
NON_MY_COUNTRY_COUNTER=0      # count domains that does not belong to my country (MY_COUNTRY_CODE)
FAILED_LOOKUPS=0              # count failed look ups for the summary

# iterate over file entries
while read L; do

    # create uri
    URI_DOMAIN=$L
    URI=$URI_BASE$URI_DOMAIN$URI_LANGUAGE

    # download json data
    RESULT_RAW=$($CURL "$URI")

    # parse json to json object data
    RESULT_JSON=$(func_parse_json "$RESULT_RAW")

    # search after information
    RESULT=$(func_get_value_from_json_obj "$RESULT_JSON" "countryCode")

    # check if query has failed
    FAILED_REQUEST=false
    RESULT_STATUS=$(func_get_value_from_json_obj "$RESULT_JSON" "status")
    if [ "$RESULT_STATUS" != "success" ]; then
        ((FAILED_LOOKUPS=FAILED_LOOKUPS+1))
        FAILED_REQUEST=true
    fi

    # check if it's my country
    if [ "$RESULT" != "$MY_COUNTRY_CODE" ]; then
        ((NON_MY_COUNTRY_COUNTER=NON_MY_COUNTRY_COUNTER+1))
    fi

    # output
    ((OUTPUT_COUNTER=OUTPUT_COUNTER+1))
    if [ "$FAILED_REQUEST" = true ]; then
        echo "  $OUTPUT_COUNTER.  $RESULT  $L (lookup failed)"
    else
        echo "  $OUTPUT_COUNTER.  $RESULT  $L"
    fi


    # throttle if necesary
    if [ "$THROTTLE" = true ]; then
        $SLEEP 0.25
    fi

done <$INPUT_FILE


# print summary msg
NON_MY_COUNTRY_PERCENTAGE=$(($NON_MY_COUNTRY_COUNTER*100/$NUM_OF_LINES))   # calculate summary percentage
echo ""
echo "$NON_MY_COUNTRY_COUNTER domains ($NON_MY_COUNTRY_PERCENTAGE%) are not hosted at $MY_COUNTRY_NAME."
echo "$FAILED_LOOKUPS lookups failed"
