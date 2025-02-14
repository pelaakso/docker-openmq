#!/bin/bash

docker tag pelaakso/openmq pelaakso/openmq:4.5
docker tag pelaakso/openmq pelaakso/openmq:4.5.2
docker tag pelaakso/openmq pelaakso/openmq:4.5.2-1

docker push --all-tags pelaakso/openmq
