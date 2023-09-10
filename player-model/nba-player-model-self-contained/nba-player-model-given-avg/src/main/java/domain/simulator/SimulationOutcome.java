package domain.simulator;

import java.util.Map;

public class SimulationOutcome {
   private final Map<String, Integer> playerPoints;
   private final Map<String, Integer> playerThreePoints;

    public SimulationOutcome(Map<String, Integer> playerPoints, Map<String, Integer> playerThreePoints) {
        this.playerPoints = playerPoints;
        this.playerThreePoints = playerThreePoints;
    }

    public Map<String, Integer> getPlayerPoints() {
        return this.playerPoints;
    }

    public Map<String, Integer> getPlayerThreePoints() {
        return this.playerThreePoints;
    }
}
