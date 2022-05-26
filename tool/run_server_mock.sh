#!/usr/bin/env bash

./tool/generate_bin_assets.sh

if [[ -z $PORT ]];then
  PORT=7070
fi

cd uploadcare_server_mock
nodemon -x "PORT=7070 dart run bin/server.dart " -e dart
