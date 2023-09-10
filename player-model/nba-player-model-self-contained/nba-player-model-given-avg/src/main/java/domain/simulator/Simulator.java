package domain.simulator;

import static domain.simulator.SimulatorUtils.normalizeAttemptPercs;
import static domain.simulator.SimulatorUtils.simulateFromProbabilities;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import domain.Player;
import domain.Team;
import org.apache.commons.math3.util.FastMath;

public class Simulator {

    public static SimulationOutcome simulator(Team team, int scoreDiff) {

        Map<String, Integer> playerPoints = initializeMap(team.getPlayers());
        Map<String, Integer> playerThreePoints = initializeMap(team.getPlayers());
        Map<String, Double> playerFtMade = initializeFtMap(team.getPlayers());

        Map<Player, Double> player2DoubleMap = normalizeAttemptPercs(team, scoreDiff);

//        for (int i = 0; i < numberOfPossessions; i++) {
//            Player playerToAttemptShot = simulateFromProbabilities(player2DoubleMap, Math.random());
//            double threePointsProp = playerToAttemptShot.getThreePointsProp();
//            double twoPointsPerc = playerToAttemptShot.getTwoPointsPerc()[scoreDiff + 35];
//            double threePointsPerc = playerToAttemptShot.getThreePointsPerc()[scoreDiff + 35];
//
//            double ftMadePerFgAttempt = playerToAttemptShot.getCumFtMadePerFgAttempted();
//
//            double rand = Math.random();
//
//            double isTwoProb = (1 - threePointsProp) * twoPointsPerc;
//            double isThreeProb = threePointsProp * threePointsPerc;
//
//            int pointsToAdd = 0;
//            if (rand < isTwoProb) {
//                pointsToAdd = 2;
//            } else if (rand < isTwoProb + isThreeProb) {
//                pointsToAdd = 3;
//                playerThreePoints.put(playerToAttemptShot.getName(), playerThreePoints.get(playerToAttemptShot.getName()) + 1);
//            }

//            playerFtMade.put(playerToAttemptShot.getName(), playerFtMade.get(playerToAttemptShot.getName()) + ftMadePerFgAttempt);
//            playerPoints.put(playerToAttemptShot.getName(), playerPoints.get(playerToAttemptShot.getName()) + pointsToAdd);
//        }
//        addFtPoints(playerPoints, playerFtMade, team.getPlayers());

        return new SimulationOutcome(playerPoints, playerThreePoints);
    }

//    private static void addFtPoints(Map<String, Integer> playerPoints, Map<String, Double> playerFtMade, List<Player> players) {
//        for (Player player : players) {
//            String name = player.getName();
//
//            double evenProb = player.getEvenProb();
//            double ftPerc = player.getFtPerc();
//
//            int points = FtModel.simulateFreeThrows(playerFtMade.get(name), 1 - evenProb, ftPerc);
//            playerPoints.put(name, playerPoints.get(name) + points);
//        }
//    }

    private static Map<String, Integer> initializeMap(List<Player> playersList) {
        Map<String, Integer> map = new HashMap<>();

        for (Player player : playersList) {
            map.put(player.getName(), 0);
        }
        return map;
    }

    private static Map<String, Double> initializeFtMap(List<Player> playersList) {
        Map<String, Double> map = new HashMap<>();

        for (Player player : playersList) {
            map.put(player.getName(), 0d);
        }
        return map;
    }

    public static int getPoisson(double lambda) {
        double L = Math.exp(-lambda);
        double p = 1.0;
        int k = 0;

        do {
            k++;
            p *= FastMath.random();
        } while (p > L);

        return k - 1;
    }

}
