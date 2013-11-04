#!/bin/sh


out=$(ps -ef | grep "wfuzz.py" | awk '/wfuzz.py/ && !/awk/ {print $2}')
kill $out
