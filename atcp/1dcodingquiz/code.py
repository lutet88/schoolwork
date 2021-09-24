from vpython import *

canvas(width=800, height=150, center=vec(200,50,0), background=color.white) 

# defining objects
ground = box(pos=vec(200,0,0), size=vec(400,2,50), color=vec(0.59,0.29,0))
carA = box(pos=vec(0,5,0), size=vec(10,10,0), color=color.blue, make_trail=True, trail_type="points", interval=100)
carB = box(pos=vec(0,5,2), size=vec(10,10,5), color=color.red, make_trail=True, trail_type="points", interval=100)

# setting initial conditions
xA = carA.pos.x
xB = carB.pos.x
vA = v0A = 20       
vB = v0B = 32.5        
aB = -5     
t = 0
dt = 0.02

# defining the graphs
graph1 = graph(width=800, height=200, xtitle='time (s)', ytitle='position (m)', xmin=0, xmax=10,ymin=0, ymax=300)
graph2 = graph(width=800, height=200, xtitle='time (s)', ytitle='velocity (m/s)', xmin=0, xmax=10,ymin=0, ymax=60)

# defining what will be plotted on graphs
f1 = gcurve(graph=graph1,color=color.blue)
f2 = gcurve(graph=graph2,color=color.red)

# making the cars move
while t < 10:
    rate(50)
    carA.pos.x = xA + vA*t
    carB.pos.x = xB + v0B*t + 0.5*aB*t*t
    vB = v0B + aB*t
    f1.plot(t,carA.pos.x)
    f1.plot(t,carB.pos.x)
    f2.plot(t,vB)
    f2.plot(t,vA)
    t = t + dt
