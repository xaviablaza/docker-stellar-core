#!/usr/bin/env bash

set -ue

function stellar_core_init_db() {
  local DB_INITIALIZED="/data/.db-initialized"

  if [ -f $DB_INITIALIZED ]; then
    echo "core db already initialized. continuing on..."
    return 0
  fi

  echo "initializing core db..."

  stellar-core --conf /stellar-core.cfg -newdb

  echo "finished initializing core db"

  touch $DB_INITIALIZED
}

function setup_gsutil() {
  echo "Setting up gsutil..."
  echo $GS_SERVICE_ACCOUNT_KEY > /tmp/gcloud-key.json
  gcloud auth activate-service-account --key-file /tmp/gcloud-key.json
  gsutil ls gs://bloom-general_cloudbuilds
  echo "gsutil configured"
}

confd -onetime -backend env -log-level error

stellar_core_init_db
setup_gsutil

exec "$@"
