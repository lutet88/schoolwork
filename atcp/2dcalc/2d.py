from vpython import *
from math import sqrt, atan, pi
from random import random


def make_grid(max_val):
  scene.background = color.white
  thickness = 0.02
  dx = 1
  xmax = max_val
  x = -xmax
  while (x <= xmax):
    y = -xmax
    gridline = curve(pos=[vector(x,y,-thickness)],color=color.black,radius=thickness)
    while (y <= xmax):
      gridline.append(vector(x,y,-thickness))
      y = y + dx
    x = x + dx
  y = -xmax
  while (y <= xmax):
    x = -xmax
    gridline = curve(pos=[vector(x,y,-thickness)],color=color.black,radius=thickness)
    while (x <= xmax):
      gridline.append(vector(x,y,-thickness))
      x = x + dx
    y = y + dx
  return

def geometric_distance(x, y):
    return sqrt(x ** 2 + y ** 2)

def render_vector(vec_start, vector, name, color=None):
    if not color:
        color = vec(random(), random(), random())
    text(text=name, align='center', color=color, pos=vec_start + vector/2)
    return arrow(pos=vec_start, axis=vector,color=color, shaftwidth=.2)

if __name__ == "__main__":
    # ask for values
    vector_num = 0
    last_response = ""
    vectors = []
    while True:
        last_response = input(f"Enter vector {vector_num+1}, or type 'end'\n")
        if last_response == "end" or not last_response:
            break
        values = [int(n) for n in last_response.split(",")[:2]]
        values.append(0)  # zero z-axiss
        vectors.append(vec(*values))
        vector_num += 1

    scalars = []
    # ask for multiplicity of each vector
    for i in range(vector_num):
        val = float(input(f"Enter multiplicity of vector {i} {vectors[i]}\n"))
        if val.is_integer():
            val = int(val)
        scalars.append(val)

    # generate result
    result = vec(0, 0, 0)
    for i in range(vector_num):
        result += vectors[i] * scalars[i]

    # generate grid with max size
    max_coord = max(abs(result.x), abs(result.y))
    make_grid(max(10, max_coord + 5))

    # get magnitude and angle
    mag = geometric_distance(result.x, result.y)
    if result.x != 0:
        angle = atan(result.y / result.x) / pi * 180
    else:
        angle = 90 if result.y > 0 else -90
    if result.x < 0 and result.y > 0:
        angle += 180
    if result.x < 0 and result.y < 0:
        angle -= 180

    # render each individual vector
    cumulative_sum = vec(0, 0, 0)
    for i in range(vector_num):
        # create vector name
        vector_name = ""
        if scalars[i] < 0:
            vector_name += "-"
        if abs(scalars[i]) != 1:
            vector_name += str(abs(scalars[i]))
        vector_name += chr(ord('A') + i)

        # render vector
        render_vector(cumulative_sum, vectors[i] * scalars[i], vector_name)

        # calculate cumulative sum for next vector
        cumulative_sum += vectors[i] * scalars[i]

    # get resulting arrow's name
    result_name = ""
    for i in range(vector_num):
        if scalars[i] >= 0 and i > 0:
            result_name += "+"
        elif scalars[i] < 0:
            result_name += "-"
        if abs(scalars[i]) != 1:
            result_name += str(abs(scalars[i]))
        result_name += chr(ord('A') + i)
    # render resulting arrow
    render_vector(vec(0, 0, 0), result, result_name, color.green)

    print(f"Resultant Vector: {result}, Magnitude: {mag}, Angle: {angle}°")

    # workaround for coroutine bug
    while True:1, 
        pass
