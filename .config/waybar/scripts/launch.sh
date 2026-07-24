#!/bin/bash

pkill waybar
pkill swaync

waybar &
swaync-client -t &