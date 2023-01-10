#!/usr/bin/env bash

########################################
# Import/export SQL dumps via S3.
# Required env vars:
# * ACTION - either 'import' or 'export'
# * DB_HOST
# * DB_NAME
# * DB_USER
# * PGPASSWORD
# * BUCKET
# Optional when ACTION=export:
# * OBJECT_NAME - default {ISO date}.sql
########################################

import () {
  echo "Importing $OBJECT_NAME from $BUCKET to $DB_HOST"
  aws s3 cp $BUCKET/$OBJECT_NAME $OBJECT_NAME
  pg_restore --clean -d $DB_NAME -Fc -h $DB_HOST -U $DB_USER < $OBJECT_NAME
}

export () {
  if [[ $OBJECT_NAME = "" ]]; then
    OBJECT_NAME=$(date -Iseconds).sql
  fi

  echo "Dumping DB from $DB_HOST"
  pg_dump -h $DB_HOST \
    -U $DB_USER \
    -Fc $DB_NAME > $OBJECT_NAME \


  echo "Backing up to $BUCKET as $OBJECT_NAME"
  aws s3 cp $OBJECT_NAME $BUCKET/$OBJECT_NAME
}


if [[ $ACTION = "import" ]]; then
  import
elif [[ $ACTION = "export" ]]; then
  export
else
  echo "ACTION must be either 'import' or 'export'"
  exit 1
fi
[[ -f $OBJECT_NAME ]] && rm $OBJECT_NAME

