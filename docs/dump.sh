#!/bin/sh

su -c "pg_dump -s -t quakes quakes | grep -v '^--' | grep -v '^$'" postgres > dump.sql
