 #GlowScript 3.1 VPython
from vpython import *
'''
title: "1D Accelerated Motion Coding Activity"
author: "_____________"
date: "02/09/2021"
'''

# Set up the canvas and background
scene.background = color.white
canvas(title='Freefall', width=700, height=700, 
center=vec(250,200,0), background=color.white) 

# Define and initialize the visual objects - ground and box
ground = box(pos=vec(300,-1,0), size=vec(200,2,50), color=vec(0.59,0.29,0))
car = sphere(pos=vec(300,400,0), size=vec(10,10,10), color=color.blue, make_trail=True,
trail_type="points", interval=50)
building = box(pos=vec(250,200,0), size=vec(80,400,5), texture=textures.stucco)


# Define and initialize variables used
x0 = car.pos.y
v = v0 = 20
xn = car.pos.x
vx = 4
t = 0
dt = 0.005
a = -9.81

# Define the graphs to be used
graph1 = graph(width=800, height=200, xtitle='time (s)', ytitle='position (m)', 
foreground=color.black, background=color.white, 
      xmin=0, xmax=20, ymin=0, ymax=500)

graph2 = graph(width=800, height=200, xtitle='time (s)', 
ytitle='velocity (m/s)', foreground=color.black, background=color.white, 
      xmin=0, xmax=20,ymin=-100, ymax=60)

# Define what will be plotted on the graphs
f1 = gcurve(graph=graph1,color=color.green)
f2 = gcurve(graph=graph2,color=color.blue)

# Iterate over time to make the car move
while car.pos.y > 0:
    rate(200)
    car.pos.y += v*dt# + 0.5 * a * t * t
    car.pos.x = xn + vx * t
    v = v + dt * a
    f1.plot(t,car.pos.y)            
    f2.plot(t,v)
    t = t + dt
print(f"time: {t}s")
print(f"ball - pos: {x0+t*v0+0.5*a*t*t}m, vel: {v0+a*t}m/s, accel: {a}m/s^2")
