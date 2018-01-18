import sys
from sympy import *

X,Y,Z,V,x,y,z = symbols('X Y Z V x y z');

## step 1: result1 is list.
def step1(L, a ,b):
    global X,Y,Z
    print "\n\n\nInput:(L,a,b):", L, a, b;
    print "###########[Step1]###########"
    result1 = solve([116.0 * ((Y / 100.0) ** (1.0/3.0)) - 16.0 - L,
        500 * ( (X / 98.81) ** (1.0 / 3.0) - (Y / 100.0) ** (1.0 / 3.0) ) - a,
        200 * ( (Y / 100.0) ** (1.0 / 3.0) - (Z / 107.32) ** (1.0 / 3.0) ) - b], [X, Y, Z]);
    for item in result1:
        X,Y,Z = item;
        print "valid value list:"
        print "X,Y,Z:",X,Y,Z
        step2(Y);
        step3(X, Y, Z);
    return;

## step 2: result2 is list.
def step2(Y):
    global V
    print "###########[Step2]###########"
    V  = solve(1.2533028 * V - 0.2370495 * V * V + 0.2456654 * (V ** 3) - 0.0215489 * ( V ** 4) + 0.000862 * ( V ** 5) - Y, V)
    print "V may has mult value:", V
    return;


## step 3: result3 is dict.
def step3(X, Y, Z):
    global x,y,z
    print "###########[Step3]###########"
    result3 = solve([X / (X + Y + Z) - x, Y / (X + Y + Z) - y, Z / (X + Y + Z) - z], [x, y, z])
    for key in result3:
        print key, ':', result3[key]

def usage():
    print "The python script usage:\n"
    print "    python test.py [L*] [a*] [b*]\n"
    print "eg: python test.py 66.54 3.45 5.7"
    print "eg: python test.py 58.2 3.6 4.91"
    print "eg: python test.py 57.89 6.77 7.26"

if __name__ == "__main__":
    length = len(sys.argv);
    if length != 4:
        usage();
        sys.exit(-1);

    L = float(sys.argv[1]);
    a = float(sys.argv[2]);
    b = float(sys.argv[3]);
    step1(L, a, b);

