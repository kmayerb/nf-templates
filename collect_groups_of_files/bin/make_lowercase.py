#!/usr/bin/env python3
import sys
with open(sys.argv[1], "r") as infile:
	with open(f"{sys.argv[1]}.lowercase.tsv", 'w') as outfile:
		for line in infile:
			outfile.write(line.lower())