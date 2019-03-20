#!/usr/bin/bash
perl -ne '/^\[DATA\]/ && s/\[DATA\]// && print' parallel.out | sort -g -t, > EMRN_paper_clean.out
