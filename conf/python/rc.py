# vim: set tw=80 ts=2 sw=2 ft=python noet:

from __future__ import print_function

import json
import sys
import datetime

#from redis import StrictRedis as Redis
#
#r = Redis()

#try:
#  import readline
#except ImportError:
#  print("Module readline not available.")
#else:
#  import rlcompleter
#  if 'libedit' in readline.__doc__:
#    readline.parse_and_bind("bind ^I rl_complete")
#  else:
#    readline.parse_and_bind("tab: complete")

#try:
#  from app import models
#  from django.conf import settings
#except:
#  print("\nCould not import Django modules.")
#else:
#  print("\nImported Django modules.")

#try:
#  from dateutil.parser import parse as parse_date
#except ImportError:
#  print("\nCould not import dateutil.")

def binary(n):
  binary_str = bin(n)[2:]
  num_bits = len(binary_str)
  padding_needed = (8 - (num_bits % 8)) % 8
  full_binary = '0' * padding_needed + binary_str
  parts = [full_binary[i:i+8] for i in range(0, len(full_binary), 8)]
  print(" ".join(parts))