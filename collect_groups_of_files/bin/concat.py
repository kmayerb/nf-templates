#!/usr/bin/env python3
import sys

files = sys.argv[1:]

outlines = list()
# COLLECT INPUTS
for file in files:
	with open(file, 'r') as fh:
		outlines.extend(fh.readlines())

# WRITE OUT TO GROUP
for line in outlines:
	sys.stdout.write(line)