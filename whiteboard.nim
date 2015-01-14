import os
from strutils import parseFloat
import sequtils
import tables
import strutils
import math

var i = 200;

echo i / 10; # 20

echo 6 mod 10; # 6

echo 10 mod 6; # 4

# The right hand side is the number to "wrap around"
echo 10 mod 10; # 0

echo 11 mod 10; # 1

# Get the number of digits is (log10 of n) + 1
echo log10(1000)+1; # 4
