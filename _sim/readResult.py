import numpy as np
import matplotlib

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import cm

from mpl_toolkits.mplot3d import Axes3D
file = open("results.dat", "r")
matrixArray = list();
minValue = 0;
maxValue = 0;
for line in file.readlines() :
    values = line.split(' ');
    values = filter(lambda x: x != '' and x != '\r' and x != '\n', values)
    valuesInt = [];
    for value in values:
        valueInt = int(value, 16)
        if (valueInt & 0x80000000) == 0x80000000:
        # if set, invert and add one to get the negative value, then add the negative sign
            valueInt = -( (valueInt ^ 0xffffffff) + 1)
        valuesInt.append(valueInt/(0x10000));

    # print valuesInt;
    gridSize = int(np.sqrt(len(valuesInt)));
    matrix = np.reshape(np.array(valuesInt), (gridSize, gridSize))
    if matrix.min() < minValue:
        minValue = matrix.min()
    if matrix.max() > maxValue:
        maxValue = matrix.max()
    matrixArray.append(matrix);

# max = list();
# for matrix in matrixArray:
#     max.append(np.absolute(matrix).max());
# plt.plot(max);
# plt.show();




x, y = np.meshgrid(np.linspace(0, gridSize-1, gridSize), np.linspace(0, gridSize-1, gridSize))

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
minValue = -0.2;
maxValue = 0.2;
ax.set_zlim3d(minValue, maxValue)

# surf = ax.plot_surface(x, y, matrixArray[i])
# print(np.max(matrix));


def animate(i):


    matrix = matrixArray[i];
    print(i);

    ax.clear()
    surf = ax.plot_surface(x, y, matrix, cmap=cm.coolwarm)
    ax.set_zlim3d(minValue, maxValue)
    return surf,

anim = animation.FuncAnimation(fig, animate,
                                   frames=range(len(matrixArray)), interval=10, blit=False)
Writer = animation.writers['ffmpeg']
writer = Writer(fps=15, metadata=dict(artist='Me'), bitrate=1800)

# plt.show()
anim.save("movie.mp4")
