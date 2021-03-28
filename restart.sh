#!/bin/bash

pkill -f "ruby main.rb"
git pull
ruby main.rb