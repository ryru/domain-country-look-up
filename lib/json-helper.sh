#!/bin/bash -u

###############################################################################
# Author  : Pascal K. (pascal@addere.ch)
# Date    : 20160604
# Project : Helper functions for working more easy with JSON.sh
# Purpose : Contains basic functionality to handle json data.
# License : BSD 3-Clause License (see License.txt)
###############################################################################

# Json parsing library
JSON_PARSER='lib/json.sh -s'

##
# Convert raw json data into a JSON object
# PARAM $1 RAW json data
# RETURN JSON Object file
func_parse_json() {
	JSON_RAW=$1
	
	RESPONSE=$(echo "$JSON_RAW" | $JSON_PARSER)

	echo "$RESPONSE"
}


##
# Parse json object data $1 according the given search parameters and returns the value
# PARAM $1 json object data
# PARAM $@ Search terms
# RETURN json object leave value
func_get_value_from_json_obj() {
	DATA_POOL=$1
	QUERY_STRING=""
	QUERY_STRING_START='\['
	QUERY_STRING_END='\]'

	if [ $# -gt 1 ]; then
		QUERY_STRING="$QUERY_STRING$QUERY_STRING_START" # start QUERY string

		shift # to ignore the first argument (DATA_POOL)
		for arg in "$@"; do
			QUOTE='\"'
			SEPERATOR=','

			# check if arg is a number (number do not need QUOTES)
			numb='^[0-9]+$'
			if ! [[ $arg =~ $numb ]] ; then
				QUERY_STRING="$QUERY_STRING$QUOTE$arg$QUOTE"
			else
				QUERY_STRING="$QUERY_STRING$arg"
			fi

			QUERY_STRING="$QUERY_STRING$SEPERATOR"
		done

		QUERY_STRING=${QUERY_STRING%?} # remove the last character (last $SEPERATOR)
		QUERY_STRING="$QUERY_STRING$QUERY_STRING_END"  # start QUERY string
	fi


	RESPONSE=$(echo "$DATA_POOL" | egrep "$QUERY_STRING" | cut -f2 | cut -d "\"" -f2)

	echo "$RESPONSE"
}
