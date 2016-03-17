#!/bin/bash
dd if=/dev/urandom of=/vagrant/http_secret bs=1024 count=1
