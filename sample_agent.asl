// Agent sample_agent in project krislet

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- turn(10); dash(10); kick(50.0, 100.0); !start.
