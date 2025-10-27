#!/bin/bash
TAG="v1.96.2@sha256:01f870b7689b5a09c1a370914fcddcac42c4b6478c9d369e1d2590dd0a66ffd0"
docker run -v "$(pwd):/lint" -w /lint ghcr.io/antonbabenko/pre-commit-terraform:$TAG run -a
