#!/bin/bash
TAG="v1.86.1@sha256:9ecf064c8d0d7c32ef19a703b3a6d1b4e1f8806cf697501f36c7790d25e849f2"
docker run -v "$(pwd):/lint" -w /lint ghcr.io/antonbabenko/pre-commit-terraform:$TAG run -a
