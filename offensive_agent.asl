// Agent offensive_agent in project krislet
// Basic Action: Find ball -> Run to Ball -> Kick to enemy goal -> repeat

/* Initial beliefs and rules */
atBall :- ball(Dir, Dis) & Dis < 0.5.
facingBall :- ball(Dir, Dis) & math.abs(Dir) < 2.

/* Initial goals */
!findBall.

/* Plans */
//Finding the goal, kicking in its direction if we are facing it.
+!findGoal : enemyGoal(Dir, Dis) <- kick(100, Dir); !findBall.
+!findGoal : selfGoal(Dir, Dis) <- kick(100, Dir+180); !findBall.
+!findGoal : ~enemyGoal <- turn(15); !!findGoal.

//Check to see if we are close to the ball
+?closeToBall : ball(Dir, Dis) & atBall <- !findGoal.
+?closeToBall : ball(Dir, Dis) <- !runToBall.
+?closeToBall : ~ball <- !findBall.

//Run to the ball if we see it
+!runToBall : facingBall <- dash(100); ?closeToBall.
+!runToBall : ball(Dir, Dis) <- turn(Dir); dash(100); ?closeToBall.
+!runToBall : ~ball <- !findBall.

//Find the ball
+!findBall : facingBall <- !runToBall.
+!findBall : ball(Dir, Dis) <- turn(Dir); !!findBall. 
+!findBall : ~ball <- turn(15); !!findBall.

//The following is required because at the start the ball may
// not be initialized. After getting out of here, the ball being
// visible or not visible will always be in the KB.
+!findBall : true <- !!findBall.