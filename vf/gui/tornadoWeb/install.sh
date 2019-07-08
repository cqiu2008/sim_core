#!/usr/bin/env bash

if $3
then
    param="--dry-run"
fi

if $4
then
    param="${param} --keep-docker-images"
fi

if [ -n "$5" ]
then
    param="${param} --docker-registry ${5}"
fi

"$2"/install.py --profile "$1" ${param}