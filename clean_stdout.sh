#!/usr/bin/bash
perl -ne '/^\[DATA\]/ && s/\[DATA\]// && print' parallel.out | sort -g -t, > cleaned_display_data.out
