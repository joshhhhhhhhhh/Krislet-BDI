package soccer;

import jason.NoValueException;
import jason.asSyntax.*;
import jason.environment.Environment;
import krislet.*;

import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Vector;

/**
 * The SoccerField environment handles the communication between Krislet instances (and the simulation server) and Jason.
 */
public class SoccerField extends Environment {
    // A map of agent numbers to Krislet instances
    private final HashMap<Integer, Krislet> krislets;
    // A map of agent numbers to threads
    private final HashMap<Integer, Thread> threads;

    public SoccerField() {
        this.krislets = new HashMap<>();
        threads = new HashMap<>();
    }

    /**
     * Create all of the Krislet instances and start a thread for each one.
     *
     * Args must contain two integers: the number of agents on team Carleton, and the number of agents on team
     * University.
     */
    @Override
    public void init(String[] args) {
        int numTeam1 = Integer.parseInt(args[0]);
        int numTeam2 = Integer.parseInt(args[1]);
        for (int i = 0; i < numTeam1 + numTeam2; i++) {
            try {
                // Figure out the team of the agent
                String team = "Carleton";
                if (i > numTeam1 - 1) {
                    team = "University";
                }

                // Create the instance and store it, as well as its thread
                Krislet krislet = new Krislet(team);
                this.krislets.put(i + 1, krislet);
                this.threads.put(i + 1, new Thread(krislet));
            } catch (SocketException | UnknownHostException e) {
                throw new RuntimeException(e);
            }
        }

        for (Thread thread : this.threads.values()) {
            thread.start();
        }
    }

    @Override
    public Collection<Literal> getPercepts(String agName) {
        // Hack to disable the percept caching mechanism. If we don't do this, it's possible that the call to
        // super.getPercepts will return null (i.e. "use the cached percepts"), but we don't want to have a perception
        // caching mechanism since the environment can be updated without this agent (or any other under Jason's control
        // doing anything).
        Literal l = Literal.parseLiteral("upToDate");
        addPercept(agName, l);
        removePercept(agName, l);

        // We'll add to the percepts that the superclass gives us. In other words, ensure addPercept, removePercept, and
        // related methods keep working.
        Collection<Literal> p = super.getPercepts(agName);

        Krislet krislet = getKrisletForAgentName(agName);
        Memory memory = krislet.getMemory();

        // Add the ball percept
        ObjectInfo ball = memory.getObject("ball");
        if (ball == null) {
            p.add(Literal.parseLiteral("~ball"));
        } else {
            p.add(new LiteralImpl("ball")
                    .addTerms(new NumberTermImpl(ball.m_direction), new NumberTermImpl(ball.m_distance)));
        }

        // If the instance hasn't been assigned a side yet, krislet.side will be '-'.
        if(krislet.side == 'r' || krislet.side == 'l'){
            // Own team's goal percept
            ObjectInfo selfGoal = memory.getObject("goal " + (krislet.side == 'r' ? 'r' : 'l'));
            if (selfGoal == null) {
                p.add(Literal.parseLiteral(("~selfGoal")));
            } else {
                p.add(new LiteralImpl("selfGoal")
                        .addTerms(new NumberTermImpl(selfGoal.m_direction), new NumberTermImpl(selfGoal.m_distance)));
            }

            // Enemy goal percept
            ObjectInfo enemyGoal = memory.getObject("goal " + (krislet.side == 'r' ? 'l' : 'r'));
            if (enemyGoal == null) {
                p.add(Literal.parseLiteral("~enemyGoal"));
            } else {
                p.add(new LiteralImpl("enemyGoal")
                        .addTerms(new NumberTermImpl(enemyGoal.m_direction), new NumberTermImpl(enemyGoal.m_distance)));
            }

            // Top of penalty box percept
            Vector<FlagInfo> fl = (Vector<FlagInfo>) memory.getFlagList();
            int w = 0;
            char s = 'l';
            if (krislet.side != s) {
                s = 'r';
            }

            for (int i = 0; i < fl.size(); i++){
                FlagInfo fi = fl.get(i);
                if (fi.getType().equals("flag p "+ s + " c")) {
                    p.add(new LiteralImpl("topOfBox")
                            .addTerms(new NumberTermImpl(fi.m_direction), new NumberTermImpl(fi.m_distance)));
                    w = 1;
                    break;
                }
            }
            if (w == 0) p.add(Literal.parseLiteral("~topOfBox"));
        } else {
            // If we don't have a side yet, we can't see the penalty box (we don't know which is ours)
            p.add(Literal.parseLiteral("~topOfBox"));
        }

        // Percept for the teammate furthest from us
        Vector<PlayerInfo> pl = (Vector<PlayerInfo>) memory.getPlayerList();
        int w = 0;
        float p_dist = 0;
        PlayerInfo furthestPlayer = null;
        for (int i = 0; i < pl.size(); i++){
            PlayerInfo player = pl.get(i);
            String p_team = player.getTeamName();
            String m_team = krislet.getTeamName();
            if(p_team.equals(m_team)) {
                if (player.m_distance > p_dist) {
                    furthestPlayer = player;
                    p_dist = player.m_distance;
                    w = 1;
                }
            }
        }
        if (w == 1) p.add(new LiteralImpl("furthestTeammate")
                .addTerms(new NumberTermImpl(furthestPlayer.m_direction), new NumberTermImpl(furthestPlayer.m_distance)));

        if (w == 0) p.add(Literal.parseLiteral("~furthestTeammate"));

        return p;
    }

    // Wait a simulator step to avoid sending two commands at once. If we do, one of them will be ignored.
    private void waitSimulatorStep() {
        try {
            Thread.sleep(SoccerParams.simulator_step);
        } catch (InterruptedException ignored) { }
    }

    @Override
    public boolean executeAction(String agName, Structure act) {
        Krislet krislet = getKrisletForAgentName(agName);

        // Parse the sentence and call the relevant Krislet method if possible.
        try {
            String functor = act.getFunctor();
            // A sentence like `turn(30)`
            if (functor.equals("turn")) {
                double moment = ((NumberTerm) act.getTerm(0)).solve();

                krislet.turn(moment);
                waitSimulatorStep();
                return true;
            // A sentence like `dash(100)`
            } else if (functor.equals("dash")) {
                double power = ((NumberTerm) act.getTerm(0)).solve();

                krislet.dash(power);
                waitSimulatorStep();
                return true;
            // A sentence like `kick(100, 30)`
            } else if (functor.equals("kick")) {
                double power = ((NumberTerm) act.getTerm(0)).solve();
                double direction = ((NumberTerm) act.getTerm(1)).solve();

                krislet.kick(power, direction);
                waitSimulatorStep();
                return true;
            }
        } catch (NoValueException e) {
            // If one of the terms isn't actually a number term, this will be raised and we'll just throw a runtime
            // exception.
            throw new RuntimeException(e);
        }

        return false;
    }

    /**
     * Return the Krislet instance associated with the given agent name.
     */
    private Krislet getKrisletForAgentName(String agName) {
        return this.krislets.get(Integer.parseInt(agName.substring(7)));
    }
}
