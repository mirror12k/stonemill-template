#!/bin/bash
cd "$(dirname "$0")" && cd ..

KEYPATH=$1
if [[ ! -f ".keys/$KEYPATH" ]]; then
	mkdir -p .keys/
	ssh-keygen -t rsa -b 2048 -f ".keys/$KEYPATH" -q -N ""
fi
