/* Goalie Agent for Krislet
   Basic behavior is as follows:
        Find team goal -> Move to team goal -> Find ball -> "Wait" for ball to come close ->
            Go to ball -> Find enemy goal -> Kick ball -> Go back to team goal -> Repeat
*/

/* Initial beliefs and rules */
atBall :- ball(DIR, DIST) & DIST < 0.5.
ballClose :- ball(DIR, DIST) & DIST < 20.0.
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

// Go to the ball; if ball not seen, find it; if ball is "close", move towards; if at ball, find enemy goal
+!goToBall : ~ball <- !findBall.
+!goToBall : ball(DIR,DIST) & atBall <- !findEnemyGoal.
+!goToBall : ball(DIR,DIST) & ballClose <- dash(80); !!goToBall.
+!goToBall : ball(DIR,DIST) <- !!goToBall.

// Find enemy goal and kick towards
+!findEnemyGoal : ~enemyGoal <- turn(15); !!findEnemyGoal.
+!findEnemyGoal : enemyGoal(DIR, DIS) <- kick(100, DIR); !findSelfGoal.