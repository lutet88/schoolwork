from vpython import *
from random import *
#GlowScript 3.0 VPython

#Create the visual elements
floor = box(pos=vector(0,-30,0), size=vector(100,4,12), color=color.white)     
crate = box(pos=vector(-50,-23,0), size=vector(10,10,5), color=color.red)    
cylinder = cylinder(pos=vector(50,-7,0), size=vector(10,42,8), color=color.green)
funny = box(pos=vector(-40,13,0), size=vector(10,10,5), color=color.blue)    

# Set initial conditions
t=0.0                                                                                                                                               
x0 = crate.pos.x
x1 = cylinder.pos.x
xf = funny.pos.x
yf = funny.pos.y

#Set the time interval
dt=0.01 

# Give the crate an initial velocity
v=10.0          
v2 = 5.0     
vx = 0
vy = 0                                                           

# Create a 'while' loop to update the position of the crate with time
while crate.pos.x < cylinder.pos.x - 5:                                                                  
    rate(100)                                                                  
    crate.pos.x = x0 + v*t    
    cylinder.pos.x = x1 - v2*t                      
    vx += random() - random()
    vy += random() - random() 
    xf = xf + vx * t
    yf = yf + vy * t 
    funny.pos.x = xf
    funny.pos.y = yf
    t=t+dt
    
    
    


