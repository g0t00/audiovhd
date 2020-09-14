import math;
import numpy as np;
import struct;
SR = 44100;                         # sample rate(Hz)
gamma = 450;                        # wave speed (1/s)
T60 = 2;                            # loss [freq.(Hz), T60(s), freq.(Hz), T60(s)]
epsilon = 1;                      # domain aspect ratio

lambda_ = 1/math.sqrt(2)             # Courant number

###### end global parameters

# begin derived parameters

k = 1/SR;                           # time step
sig0 = 6*math.log(10)/T60;               # loss parameter

# stability condition/scheme parameters

h = gamma*k/lambda_;                 # find grid spacing
Nx = math.floor(math.sqrt(epsilon)/h);        # number of x-subdivisions of spatial domain
Ny = math.floor(1/(math.sqrt(epsilon)*h));    # number of y-subdivisions of spatial domain
h = math.sqrt(epsilon)/Nx;
lambda_ = gamma*k/h;                        # reset Courant number

s0 = (2.-4.*lambda_**2.)/(1.+sig0*k);
s1 = lambda_**2./(1.+sig0*k);
t0 = -(1.-sig0*k)/(1.+sig0*k);
def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])
print("s0:  %f, %s" % (s0, float_to_hex(np.float32(s0))));
print("s1:  %f, %s" % (s1, float_to_hex(np.float32(s1))));
print("t0: %f, %s" % (t0, float_to_hex(np.float32(t0))));
