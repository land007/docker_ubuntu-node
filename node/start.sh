#!/bin/bash
/usr/bin/nohup supervisor -w /node/ /node/main.js & > /tmp/node.out 2>&1 & bash