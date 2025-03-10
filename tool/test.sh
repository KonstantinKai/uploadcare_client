#!/usr/bin/env bash

set -e

SERVER_PID=

onExit() {
	kill -9 $SERVER_PID
}

trap "onExit" $(seq 0 15)

if [[ -z $PORT ]]; then
	PORT=7070
fi

cd uploadcare_server_mock
PORT=$PORT dart bin/server.dart --disable-logs &

SERVER_PID=$!

CHECK_SERVER=true
ATTEMPTS=10

while $CHECK_SERVER; do
	if nc -z 127.0.0.1 $PORT &>/dev/null; then
		CHECK_SERVER=false
	elif [[ $ATTEMPTS -eq 0 ]]; then
		exit 1
	else
		ATTEMPTS=$(($ATTEMPTS - 1))
	fi
	sleep 2
done

cd ../uploadcare_client

flutter test

kill -9 $SERVER_PID
