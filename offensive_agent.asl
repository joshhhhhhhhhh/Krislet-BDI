// Agent offensive_agent in project krislet

/* Initial beliefs and rules */
atBall :- ball(X, Y) & Y < 0.5.
ballNear :- ball(X, Y) & Y < 8.

/* Initial goals */
!findBall.

/* Plans */
//Finding the goal, kicking in its direction if we are facing it.
+!findGoal : ~enemyGoal <- turn(15); !!findGoal.
+!findGoal : enemyGoal(X, Y) & facingEnemyGoal <- kick(200, X); !findBall.
+!findGoal : enemyGoal(X, Y) <- turn(X); !!findGoal.

//Check to see if we are close to the ball
+?closeToBall : ball(X, Y) & atBall <- !findGoal.
+?closeToBall : ball(X, Y) <- !runToBall.
+?closeToBall : ~ball <- !findBall.

//Run to the ball if we see it
+!runToBall : ball(X, Y) & not ballNear <- turn(X); dash(Y*20); ?closeToBall.//; ?atBall.
+!runToBall : ball(X, Y) <- turn(X); dash(Y*8); ?closeToBall.//; ?atBall.
+!runToBall : ~ball <- !findBall.

//Find the ball
+!findBall : facingBall & ball(X, Y) <- !runToBall.
+!findBall : ball(X, Y) <- turn(X); !!findBall. 
+!findBall : ~ball <- turn(15); !!findBall.
//The following is required because at te start the ball may
// not be initialized. After getting out of here, the ball being
// visible or not visible will always be in the KB.
+!findBall : true <- !!findBall.


//+!start : true <- turn(10); dash(10); kick(50.0, 100.0); !start.