/* Goalie Agent for Krislet
   Basic behavior is as follows:
        Find team goal -> Move to team goal -> Find ball -> "Wait" for ball to come close ->
            Go to ball -> Find enemy goal -> Kick ball -> Go back to team goal -> Repeat
*/

/* Initial beliefs and rules */
atBall :- ball(DIR, DIST) & DIST < 0.5.
ballClose :- ball(DIR, DIST) & DIST < 25.0.
atNet :- selfGoal(DIR, DIST) & DIST < 3.0.

/* Initial goals */
!findSelfGoal.

/* Plans */
// Find own team's net
+!findSelfGoal : ~selfGoal <- turn(15); !findSelfGoal.
+!findSelfGoal : selfGoal(DIR, DIST) <- turn(DIR); !goToGoal.

// Go to own team's net
+!goToGoal : ~selfGoal <- !findSelfGoal.
+!goToGoal : selfGoal(DIR,DIST) & atNet <- !findBall.
+!goToGoal : selfGoal(DIR,DIST) <- dash(100); !!goToGoal.

// Find the ball
+!findBall : ~ball <- turn(15); !findBall.
+!findBall : ball(DIR, DIST) <- turn(DIR); !goToBall.

// Go to the ball; if ball not seen, find it; if ball is "close", move towards; if at ball, perform an action with the ball
+!goToBall : ~ball <- !findBall.
+!goToBall : ball(DIR,DIST) & atBall <- !actOnBall.
+!goToBall : ball(DIR,DIST) & ballClose <- turn(DIR); dash(100); !!goToBall.
+!goToBall : ball(DIR,DIST) <- !!goToBall.

// Perform an action with the ball
+!actOnBall : furthestTeammate(DIR, DIS) & ~selfGoal <- kick(100, DIR); !findSelfGoal.
+!actOnBall : enemyGoal(DIR, DIS) <- kick(100, DIR); !findSelfGoal.
+!actOnBall : ~enemyGoal & selfGoal(X, Y) <- kick(100, 180); !findSelfGoal.
+!actOnBall : true <- turn(15); !!actOnBall.
