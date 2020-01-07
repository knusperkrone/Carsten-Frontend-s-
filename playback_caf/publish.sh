#! /bin/sh
webdev build --no-release -o ../private/public && cd ../private && firebase deploy && cd -
