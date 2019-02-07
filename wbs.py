#! /usr/bin/env python3
#
# wbs.py - generate a WBS from the input stream.
#

import sys

values = [10] + [0] * 10
level = 0

def wbs():
    global level, values
    values[level] += 1
    return '.'.join([str(x) for x in values[0:level+1] if x != 0])

names = set()
def wbs_check(r):
    global names
    if r in names:
        print('warning: duplicate name for WBS entry!', r)
    else:
        names.add(r)

print('Level', 'WBS', 'Name', sep=',')
for l in sys.stdin:
    l = l[0:-1].lstrip() # strip newline

    # process WBS commands
    posn = l.find(':')
    if posn == -1:
        continue
    else:
        kw = l[0:posn]
        rest = l[posn+1:]
    if kw == 'WBSBEGIN':
        print(level+1, wbs(), rest, sep=',')
        wbs_check(rest)
        level += 1
    elif kw == 'WBS':
        print(level+1, wbs(), rest, sep=',')
        wbs_check(rest)
    elif kw == 'WBSEND':
        # print(level+1, wbs(), rest, sep=',')
        level -= 1
        for i in range(10):
            if i > level:
               values[i] = 0
    else:
        pass

            
    
