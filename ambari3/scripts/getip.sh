#!/bin/bash
ifconfig |grep inet |grep -v 127 |grep -v '::1' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' |cut -d ' ' -f2
