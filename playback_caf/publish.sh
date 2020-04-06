#! /bin/sh
webdev build --release -o ../private/public && cd ../private && firebase deploy && cd -
