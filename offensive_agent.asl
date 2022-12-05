// Agent offensive_agent in project krislet

/* Initial beliefs and rules */
atBall :- ball(X, Y) & Y < 0.5.
/* Initial goals */

!findBall.

/* Plans */
//After shooting on goal, find the ball
//+!shotOnGoal : true <- !findBall.
//When I have possesion and am far from goal, dash towards goal
//+!setupShot : enemyGoal(X, Y) & Y>=30 <- kick(5, X); !runToBall.
//When I have possession and am close to goal, kick ball to goal
//+!setupShot : enemyGoal(X, Y) & Y<30 <- kick(50, X+0.5); !shotOnGoal.

//+!setupShot : ~enemyGoal <- !findGoal.
//+!setupShot : not atBall <- !runToBall.

//When I have possession and cannot see the goal, turn until I see it
+?atBall : enemyGoal(X, Y) <- kick(50, X); !findBall.
+?atBall : ~enemyGoal <- turn(10); ?atBall.
//When I have no possession, run to ball but stay within offensive range

+!runToBall : facingBall & ball(X, Y) <- dash(Y); !runToBall; ?atBall.
+!runToBall : ball(X, Y) <- !findBall.
+!runToBall : ~ball <- !findBall.

+facingBall : ball(X, Y) <- dash(Y); !runToBall; ?atBall.
+facingBall : ~ball <- !findBall.
//+facingBall.

+!findBall : facingBall & ball(X, Y) <- dash(Y); !runToBall; ?atBall.
+!findBall : ball(X, Y) <- turn(X); !findBall. 
+~ball <- !findBall.
+!findBall : ~ball <- turn(10); !findBall.
+!findBall : true <- !findBall.


//+!start : true <- turn(10); dash(10); kick(50.0, 100.0); !start.