// Agent defender_agent in project krislet
// Defenders are the playmakers of soccer.
// In an actual game of soccer you will see wide sweeping runs and crosses being sent by defenders
// This defender will attempt to be a playmaker, where its greatest desire is to make a play by passing the ball
// towards one of it's teammates

/* Initial beliefs and rules */
atBall :- ball(DIR, DIST) & DIST < 0.5.
nearNet :- selfGoal(DIR, DIST) & DIST < 20.

/* Initial goals */
!findGoal.

/* Plans */
// Find the furthest teammate and pass the ball in its direction.
+!passToTeammate : ~ball <- !findBall.
+!passToTeammate : ~furthestTeammate <- turn(15);!passToTeammate.
+!passToTeammate : topOfBox(X,Y) & furthestTeammate(DIR,DIST) <- kick(50, DIR);!findGoal.
+!passToTeammate : ~topOfBox & furthestTeammate(DIR,DIST) <- kick(100, DIR);!findGoal.

// Run to the ball if it is seen
+!goToBall : ~ball <- !findBall.
+!goToBall : ball(DIR,DIST) & atBall <- !passToTeammate.
+!goToBall : ball(DIR,DIST) <- dash(100); !!goToBall.

// Find the ball
+!findBall : ~ball <- turn(15); !findBall.
+!findBall : ball(DIR, DIST) <- turn(DIR);!goToBall.

// Go to own net
+!goToGoal : ~topOfBox <- !findGoal.
+!goToGoal : topOfBox(DIR,DIST) & nearNet <- !findBall.
+!goToGoal : topOfBox(DIR,DIST) <- dash(100); !!goToGoal.

// Find Own Net
+!findGoal : ~topOfBox <- turn(15); !findGoal.
+!findGoal : topOfBox(DIR, DIST) <- turn(DIR);!goToGoal.

