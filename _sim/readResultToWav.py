import numpy as np
import matplotlib

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import cm
import wave
import struct

from mpl_toolkits.mplot3d import Axes3D
file = open("results.dat", "r")
matrixArray = list();
minValue = 0;
maxValue = 0;
counter = 0;
for line in file.readlines() :
    if counter % 1000 == 0:
        print(counter);


    counter = counter + 1
    values = line.split(' ');
    values = filter(lambda x: x != '' and x != '\r' and x != '\n', values)
    valuesInt = [];
    for value in values:
        valueInt = int(value, 16)
        if (valueInt & 0x80000000) == 0x80000000:
        # if set, invert and add one to get the negative value, then add the negative sign
            valueInt = -( (valueInt ^ 0xffffffff) + 1)
        valuesInt.append(valueInt/(0x10000));

    gridSize = int(np.sqrt(len(valuesInt)));
    if gridSize == 60:
        matrix = np.reshape(np.array(valuesInt), (gridSize, gridSize))
        if matrix.min() < minValue:
            minValue = matrix.min()
        if matrix.max() > maxValue:
            maxValue = matrix.max()
        matrixArray.append(matrix);
print (matrixArray)
# max = list();
# for matrix in matrixArray:
#     max.append(np.absolute(matrix).max());
# plt.plot(max);
# plt.show();
# print(matrixArray)
signal = [];
for matrix in matrixArray:
    signal.append(matrix[30][30]);
# signal = signal / np.max(signal)
plt.plot(signal);
plt.show();
# fX = np.int16(signal*(2**15))
# # print (fX);
# file = wave.open('test.wav', 'w')
# sr = 44100
# file.setparams((1, 2, sr, len(matrixArray), 'NONE', 'noncompressed'))
# for value in fX:
#     file.writeframesraw(struct.pack('<h', value));
# file.writeframes(signal)
# file.close()
