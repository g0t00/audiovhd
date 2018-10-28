import numpy as np
import matplotlib

import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import cm

from mpl_toolkits.mplot3d import Axes3D
simulationLength = 1800
file = open("results.dat", "r")
matrixArray = list();
for i in range(simulationLength):
    values = file.readline().split(' ');
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
    matrixArray.append(matrix);
x, y = np.meshgrid(np.linspace(0, gridSize-1, gridSize), np.linspace(0, gridSize-1, gridSize))

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# surf = ax.plot_surface(x, y, matrixArray[i])
# print(np.max(matrix));


def animate(i):

    print(i)
    ax.clear()
    print(matrix.shape);
    surf = ax.plot_surface(x, y, matrixArray[i], cmap=cm.coolwarm)
    return surf,

anim = animation.FuncAnimation(fig, animate,
                                   frames=range(simulationLength), interval=10, blit=False)
Writer = animation.writers['ffmpeg']
writer = Writer(fps=15, metadata=dict(artist='Me'), bitrate=1800)

anim.save("movie.mp4")
# plt.show()
