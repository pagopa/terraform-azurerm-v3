#!/bin/bash
TAG="v1.77.0@sha256:64ce1e4b99d85497fe646db0724669039b079b45fa8cd503b4dc23dbdca490ae"
docker run -v "$(pwd):/lint" -w /lint ghcr.io/antonbabenko/pre-commit-terraform:$TAG run -a
