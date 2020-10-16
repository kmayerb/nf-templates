import os
import tarfile
import sys

tarname = sys.argv[1]
files = sys.argv[2:]
tar = tarfile.open("sample.tar.gz", "w:gz")
for name in files:
	os.system()
    tar.add(name)
tar.close()