#!/usr/bin/env bash

git_clone_or_update() {
    set -e

    local path=$1
    local repo=$2
    local version=$3

    if [ "x$version" = "x" ]; then
        version="master"
    fi
    if [ -d "$path" ]; then
        pushd "$path"
        git checkout master
        git pull
        git checkout "$version"
        popd
    else
        git clone "$repo" "$path"
        pushd "$path"
        git checkout "$version"
        popd
    fi
    set +e
}