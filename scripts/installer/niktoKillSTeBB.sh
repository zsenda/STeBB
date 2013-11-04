#!/bin/sh

out=$(ps -ef | grep "nikto.pl" | awk '/nikto.pl/ && !/awk/ {print $2}')
kill $out


