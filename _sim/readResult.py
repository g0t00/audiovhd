import numpy as np
import matplotlib

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import cm
from scipy import signal
from mpl_toolkits.mplot3d import Axes3D
file = open("results.dat", "r")
matrixArray = list();
minValue = 0;
maxValue = 0;
counter = 0;
meanValue = [];
potEnergy = [];
kinEnergy = [];
for line in file.readlines():
    if counter == 100:
        break;
    counter = counter + 1 ;
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

        matrix = np.array(valuesInt);
        matrix = matrix.reshape((gridSize, gridSize))
        matrixSmall = [];
        gridSize = gridSize//2;
        for x in range(gridSize):
            row = [];
            for y in range(gridSize):
                row.append(matrix[x*2, y*2])
            matrixSmall.append(row);
        matrix = np.array(matrixSmall)
        if matrix.min() < minValue:
            minValue = matrix.min()
        if matrix.max() > maxValue:
            maxValue = matrix.max()
        mean = matrix.mean();
        meanValue.append(mean);
        # potEnergy.append(matrix.sum());
        potEnergy.append(matrix.sum());
        if len(matrixArray) > 0:
            kinEnergy.append(np.power(np.subtract(matrix, matrixArray[-1]), 2).sum());
        matrixArray.append(matrix);
# plt.subplot(211)
# plt.plot(potEnergy);
# plt.subplot(212)
# plt.plot(kinEnergy);
# plt.show();


# max = list();
# for matrix in matrixArray:
#     max.append(np.absolute(matrix).max());
# plt.plot(max);
# plt.show();
# print(matrixArray)



x, y = np.meshgrid(np.linspace(0, gridSize-1, gridSize), np.linspace(0, gridSize-1, gridSize))

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
#minValue = -0.2;
#maxValue = 0.2;
print ("%f %f"%(minValue, maxValue));
# ax.set_zlim3d(minValue, maxValue)
# ax.title = str(0)
# surf = ax.plot_surface(x, y, matrixArray[0])
# print(np.max(matrix));


def animate(i):


    matrix = matrixArray[i];
    print(matrix.shape);
    print(i);

    ax.clear()
    # ax.title = str(i)
    surf = ax.plot_surface(x, y, matrix, cmap=cm.coolwarm, vmin=minValue/4, vmax=maxValue/4)
    ax.set_zlim3d(minValue, maxValue)
    return surf,

anim = animation.FuncAnimation(fig, animate,
                                   frames=range(len(matrixArray)), interval=20, blit=False)
Writer = animation.writers['ffmpeg']
writer = Writer(fps=30, metadata=dict(artist='Me'))
#
anim.save("movie.mp4", dpi=400)


# plt.show()
