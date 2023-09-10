package domain.simulator;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import domain.Player;
import domain.Team;

public class SimulatorUtils {

    protected static Map<Player, Double> normalizeAttemptPercs(Team team, int scoreDiff) {

        Map<Player, Double> percAttemptedPerPlayer = new HashMap<>();
//        for (Player player : team) {
//            double prob = player.getPercShotsAttempted()[scoreDiff + 35];
//            percAttemptedPerPlayer.put(player, prob);
//        }

        return normalizePercentagesWithoutPlayers(percAttemptedPerPlayer, team.getStarters());
    }

    protected static Player simulateFromProbabilities(Map<Player, Double> normalizeAttemptPercs, double rand) {
        for (Player player : normalizeAttemptPercs.keySet()) {
            double prob = normalizeAttemptPercs.get(player);
            if ((rand -= prob) < 0) {
                return player;
            }
        }
        return normalizeAttemptPercs.keySet().stream().findAny().get();
    }

    private static Map<Player, Double> normalizePercentagesWithoutPlayers(Map<Player, Double> percAttemptedPerPlayer, List<Player> players) {
        double playersToExcludeSum = percAttemptedPerPlayer.keySet().stream().filter(players::contains).mapToDouble(percAttemptedPerPlayer::get).sum();
        double restPlayersSUm = percAttemptedPerPlayer.keySet().stream().filter(k -> !players.contains(k)).mapToDouble(percAttemptedPerPlayer::get).sum();

        for (Player player : percAttemptedPerPlayer.keySet()) {
            if (!players.contains(player)) {
                percAttemptedPerPlayer.put(player, percAttemptedPerPlayer.get(player) * (1 - playersToExcludeSum) / restPlayersSUm);
            }
        }
        return percAttemptedPerPlayer;
    }

    public static int simulateHomeWinningMarginFromProbs(Double[] probs) {
        double rand = Math.random();
        for (int i = 0; i < probs.length; i++) {
            if (rand < probs[i]) {
                return i - 35;
            }
            rand -= probs[i];
        }
        return probs.length - 1 - 35;
    }
}
