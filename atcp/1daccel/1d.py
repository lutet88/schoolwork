 #GlowScript 3.1 VPython
from vpython import *
'''
title: "1D Accelerated Motion Coding Activity"
author: "_____________"
date: "02/09/2021"
'''

# Set up the canvas and background
scene.background = color.white
canvas(title='1D Accelerated Motion Coding Activity', width=800, height=150, 
center=vec(250,20,0), background=color.white) 

# Define and initialize the visual objects - ground and box
ground = box(pos=vec(220,0,0), size=vec(500,2,50), color=vec(0.59,0.29,0))
car = box(pos=vec(50,5,0), size=vec(10,10,5), color=color.blue, make_trail=True,
trail_type="points", interval=50)
truck = box(pos=vec(400,5,0), size=vec(10,10,5), color=color.red, make_trail=True,
trail_type="points", interval=50)


# Define and initialize variables used
x0 = car.pos.x
v = v0 = 20
t = 0
dt = 0.002
a = 4
xtruck = truck.pos.x
vtruck = -20

# Define the graphs to be used
graph1 = graph(width=800, height=200, xtitle='time (s)', ytitle='position (m)', 
foreground=color.black, background=color.white, 
      xmin=0, xmax=10, ymin=0, ymax=500)

graph2 = graph(width=800, height=200, xtitle='time (s)', 
ytitle='velocity (m/s)', foreground=color.black, background=color.white, 
      xmin=0, xmax=10,ymin=0, ymax=60)

# Define what will be plotted on the graphs
f1 = gcurve(graph=graph1,color=color.green)
f2 = gcurve(graph=graph2,color=color.blue)
f3 = gcurve(graph=graph1,color=color.red)

# Iterate over time to make the car move
while car.pos.x < truck.pos.x - 10:
    rate(500)
    car.pos.x += v*dt# + 0.5 * a * t * t
    v = v + dt * a
    truck.pos.x = xtruck + vtruck * t
    f1.plot(t,car.pos.x)            
    f2.plot(t,v)
    f3.plot(t,truck.pos.x)
    t = t + dt
print(f"time: {t}s")
print(f"car - pos: {x0+t*v0+0.5*a*t*t}m, vel: {v0+a*t}m/s, accel: {a}m/s^2")
print(f"truck - pos: {xtruck+vtruck*t}m, vel: {vtruck}m/s, accel: {0}m/s^2")
