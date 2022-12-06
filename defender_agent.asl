// Agent defender_agent in project krislet
// Defenders are the playmakers of soccer.
// In an actual game of soccer you will see wide sweeping runs and crosses being sent by defenders
// This defender will attempt to be a playmaker, where its greatest desire is to make a play by passing the ball
// towards one of it's teammates

/* Initial beliefs and rules */
atBall :- ball(DIR, DIST) & DIST < 0.5.
atNet :- selfGoal(DIR, DIST) & DIST < 0.5.

/* Initial goals */
!findGoal.

/* Plans */
// Find a teammate and pass the ball in its direction.
+!passToTeammate : ~ball <- !findBall.
+!passToTeammate : ~teammate <- turn(15);!passToTeammate.
+!passToTeammate : selfGoal(X,Y) & teammate(DIR,DIST) <- kick(50, DIR);!findGoal.
+!passToTeammate : ~selfGoal & teammate(DIR,DIST) <- kick(100, DIR);!findGoal.

// Run to the ball if it is seen
+!goToBall : ~ball <- !findBall.
+!goToBall : ball(DIR,DIST) & atBall <- !passToTeammate.
+!goToBall : ball(DIR,DIST) <- dash(100); !!goToBall.

// Find the ball
+!findBall : ~ball <- turn(15); !findBall.
+!findBall : ball(DIR, DIST) <- turn(DIR);!goToBall.

// Go to own net
+!goToGoal : ~selfGoal <- !findGoal.
+!goToGoal : selfGoal(DIR,DIST) & atNet <- !findBall.
+!goToGoal : selfGoal(DIR,DIST) <- dash(100); !!goToGoal.

// Find Own Net
+!findGoal : ~selfGoal <- turn(15); !findGoal.
+!findGoal : selfGoal(DIR, DIST) <- turn(DIR);!goToGoal.

