import sys


input = "".join(sys.argv[1:])
result = (eval(input))
if result >= 1:
    print(" ",end="")
else:
    print("-s",round(result, 3), end="")
