#!/bin/bash

# Simple test
./bin/mayfly -l 10 README.rdoc &

sleep 2

ab -n 10  http://192.168.1.3:7887/mayfly/
