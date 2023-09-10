package domain.simulator;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PlayerModelOutput {

    private final String playerName;
    private final String playerTeam;
    private final List<PlayerSimulationOutcome> playerSimulationOutcomeList;
    private final Map<Integer, Double> pointsMap;
    private final Map<Integer, Double> threesMap;
    private final Map<Integer, Double> threesAttemptedMap;
    private final Map<Integer, Double> twosMap;
    private final Map<Integer, Double> twosAttemptedMap;
    private final Map<Integer, Double> ftsMap;
    private final Map<Integer, Double> ftsAttemptedMap;
    private final double fieldGoalsAttempted;
    private final double fgMultiplier;
    private final double zeroFgAttProb;
    private final double zeroFtAttProb;

    public PlayerModelOutput(String playerName, String playerTeam, List<PlayerSimulationOutcome> playerSimulationOutcomeList, double fieldGoalAttempted, double fgMultiplier) {
        this.playerName = playerName;
        this.playerTeam = playerTeam;
        this.playerSimulationOutcomeList = playerSimulationOutcomeList;
        this.pointsMap = new HashMap<>();
        this.threesMap = new HashMap<>();
        this.threesAttemptedMap = new HashMap<>();
        this.twosMap = new HashMap<>();
        this.twosAttemptedMap = new HashMap<>();
        this.ftsMap = new HashMap<>();
        this.ftsAttemptedMap = new HashMap<>();
        buildPointsMap();
        this.fieldGoalsAttempted = fieldGoalAttempted;
        this.fgMultiplier = fgMultiplier;
        this.zeroFgAttProb = playerSimulationOutcomeList.stream().mapToDouble(p->p.getZeroFgAttempted()).average().getAsDouble();
        this.zeroFtAttProb = playerSimulationOutcomeList.stream().mapToDouble(p->p.getZeroFtAttempted()).average().getAsDouble();
    }

    public String getPlayerName() {
        return playerName;
    }

    public String getPlayerTeam() {
        return playerTeam;
    }

    private void buildPointsMap() {
        for (PlayerSimulationOutcome playerSimulationOutcome : this.playerSimulationOutcomeList) {

            addToMap(pointsMap, playerSimulationOutcome.getPoints(), this.playerSimulationOutcomeList.size());
            addToMap(threesMap, playerSimulationOutcome.getThreePointers(), this.playerSimulationOutcomeList.size());
            addToMap(threesAttemptedMap, playerSimulationOutcome.getThreePointersAttempted(), this.playerSimulationOutcomeList.size());
            addToMap(ftsMap, playerSimulationOutcome.getFtScored(), this.playerSimulationOutcomeList.size());
            addToMap(ftsAttemptedMap, playerSimulationOutcome.getFtAttempted(), this.playerSimulationOutcomeList.size());
            addToMap(twosMap, playerSimulationOutcome.getTwoPointers(), this.playerSimulationOutcomeList.size());
            addToMap(twosAttemptedMap, playerSimulationOutcome.getTwoPointersAttempted(), this.playerSimulationOutcomeList.size());

        }
    }

    private void addToMap(Map<Integer, Double> map, int value, int size) {
        double probToAdd = 1d / (double) size;
        map.merge(value, probToAdd, Double::sum);
    }

    public double getPointsAvg() {
        return this.pointsMap.keySet().stream().mapToDouble(k -> this.pointsMap.get(k) * k).sum();
    }

    public double getLessThanXPointsProb(double points) {
        return getLessThanXForMap(points, this.pointsMap);

    }

    public double getLessThanXThreesProb(double threes) {
        return getLessThanXForMap(threes, this.threesMap);
    }

    private double getLessThanXForMap(double value, Map<Integer, Double> map) {
        return map.keySet().stream().
                filter(k -> k < value).
                mapToDouble(k -> map.get(k)).
                sum();
    }

    public Map<Integer, Double> getPointsMap() {
        return pointsMap;
    }

    public Map<Integer, Double> getThreesMap() {
        return threesMap;
    }

    public Map<Integer, Double> getFtsMap() {
        return ftsMap;
    }

    public double getFieldGoalsAttempted() {
        return fieldGoalsAttempted;
    }

    public double getFgMultiplier() {
        return fgMultiplier;
    }

    public Map<Integer, Double> getThreesAttemptedMap() {
        return threesAttemptedMap;
    }

    public Map<Integer, Double> getTwosMap() {
        return twosMap;
    }

    public Map<Integer, Double> getTwosAttemptedMap() {
        return twosAttemptedMap;
    }

    public Map<Integer, Double> getFtsAttemptedMap() {
        return ftsAttemptedMap;
    }

    public double getZeroFgAttProb() {
        return zeroFgAttProb;
    }

    public double getZeroFtAttProb() {
        return zeroFtAttProb;
    }
}
