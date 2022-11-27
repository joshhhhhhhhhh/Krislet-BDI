package soccer;

import jason.NoValueException;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Structure;
import jason.environment.Environment;
import krislet.Krislet;

import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.HashMap;

public class SoccerField extends Environment {
    private final HashMap<Integer, Krislet> krislets;
    private final HashMap<Integer, Thread> threads;

    public SoccerField() {
        this.krislets = new HashMap<>();
        threads = new HashMap<>();
    }

    @Override
    public void init(String[] args) {
        int numTeam1 = Integer.parseInt(args[0]);
        int numTeam2 = Integer.parseInt(args[1]);
        for (int i = 0; i < numTeam1 + numTeam2; i++) {
            try {
                String team = "Carleton";
                if (i > numTeam1 - 1) {
                    team = "University";
                }

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
    public boolean executeAction(String agName, Structure act) {
        Krislet krislet = getKrisletForAgentName(agName);

        try {
            String functor = act.getFunctor();
            if (functor.equals("turn")) {
                double moment = ((NumberTerm) act.getTerm(0)).solve();

                krislet.turn(moment);
                return true;
            } else if (functor.equals("dash")) {
                double power = ((NumberTerm) act.getTerm(0)).solve();

                krislet.dash(power);
                return true;
            } else if (functor.equals("kick")) {
                double power = ((NumberTerm) act.getTerm(0)).solve();
                double direction = ((NumberTerm) act.getTerm(1)).solve();

                krislet.kick(power, direction);
                return true;
            }
        } catch (NoValueException e) {
            throw new RuntimeException(e);
        }

        return false;
    }

    private Krislet getKrisletForAgentName(String agName) {
        return this.krislets.get(Integer.parseInt(agName.substring(7)));
    }
}
