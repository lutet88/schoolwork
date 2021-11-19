from vpython import *

ball = sphere(pos=vec(-3.5, -4.79, 0), radius=0.2, color=color.white, make_trail=True, interval=5, trail_type="points")
#ground = box(pos=vec(0, -5, 0), size=vec(7, 0.1, 3), color=color.green)
planet = sphere(pos=vec(0, 0, 0), radius=1)

m = 0.3
v = vec(25, 0, 0)
v_hat = v / mag(v)
g = vec(0, -9.81, 0)
f_g = m * g
c = 0.08
f_air = c * mag(v)**2 * -v_hat
f_net = f_g + f_air
t = 0
dt = 0.01

while True:
    rate(100)
    g = ball.pos - planet.pos
    g = g / mag(g) * 9.81
    v_hat = v / mag(v)
    f_air = c * mag(v)**2 * -v_hat
    f_net = f_g + f_air
    v += f_net / m * dt
    ball.pos += v * dt
    t += dt
    print(f_air, v_hat, v)

input()
exit()
