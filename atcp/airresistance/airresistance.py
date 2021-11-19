from vpython import *

ball = sphere(pos=vec(-3.5, -4.79, 0), radius=0.2, color=color.white, make_trail=True, interval=5, trail_type="points")
ground = box(pos=vec(0, -5, 0), size=vec(7, 0.1, 3), color=color.green)

m = 0.3
v = vec(25, 30, 0)
v_hat = v / mag(v)
g = vec(0, -9.81, 0)
f_g = m * g
c = 0.08
f_air = c * mag(v)**2 * -v_hat
f_net = f_g + f_air
t = 0
dt = 0.01

while ball.pos.y >= ground.pos.y + ball.radius:
    rate(100)
    v_hat = v / mag(v)
    f_air = c * mag(v)**2 * -v_hat
    f_net = f_g + f_air
    v += f_net / m * dt
    ball.pos += v * dt
    t += dt
    print(f_air, v_hat, v)

input()
exit()
