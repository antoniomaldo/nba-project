package domain.simulator;

import domain.Player;

import domain.Team;
import domain.models.playerpoints.MissingPointsExpModel;
import domain.simulator.fgdistribution.FgDistribution;
import domain.simulator.fgdistribution.FgDistributionModel;
import domain.simulator.prepopulated.PrePopPlayer;
import hex.genmodel.easy.exception.PredictException;
import org.apache.commons.math3.util.FastMath;

import java.util.*;

public class TeamSimulator {

    public static final List<FgDistribution> FG_DISTRIBUTION_MODEL = FgDistributionModel.getFgDistribution();
    private static final double MIN_FG_EXP = FG_DISTRIBUTION_MODEL.stream().mapToDouble(FgDistribution::getFgExp).min().getAsDouble();
    private static final double MAX_FG_EXP = FG_DISTRIBUTION_MODEL.stream().mapToDouble(FgDistribution::getFgExp).max().getAsDouble();
    public static final Random RANDOM = new Random();

    private static final double TOLERANCE = 0.2;


    public static Map<String, PlayerModelOutput> simulateForTeam(Team team, double ownPointsExp, double oppPointsExp) throws PredictException {
        double percFactor = 0;
        List<PrePopPlayer> prePopPlayerList = prepopulatePlayers(team, ownPointsExp, oppPointsExp, percFactor);
        List<PlayerModelOutput> teamModelOutput = simulateTeamForFgMultiplier(prePopPlayerList, percFactor);

        double missingPointsPred = MissingPointsExpModel.missingPointsPred(FastMath.max(0, 13 - team.getPlayers().size()), FastMath.abs(ownPointsExp - oppPointsExp));
//
        if (false) { //not normalized
            return transformToMap(teamModelOutput);

        }

        double teamExpPointsPred = ownPointsExp - missingPointsPred;
        double teamSimExp = getTeamSimExp(teamModelOutput);

//        double pointsDiff = teamSimExp - ownPointsExp;

//        for(PrePopPlayer prePopPlayer : prePopPlayerList){
//            double baseFgAttemptedPred = prePopPlayer.getBaseFgAttemptedPred();
//            prePopPlayer.setNormalizeFgAttempted(FieldGoalNormalizerGIvenPointsDiff.normalize(baseFgAttemptedPred, pointsDiff));
//        }

        teamModelOutput = simulateTeamForFgMultiplier(prePopPlayerList, percFactor);
//        return transformToMap(teamModelOutput);
        double upperMultiplier;
        double lowerMultiplier;

        if (teamSimExp > teamExpPointsPred) {
            upperMultiplier = 0;
            lowerMultiplier = -0.2;
        } else {
            upperMultiplier = 0.2;
            lowerMultiplier = 0;
        }

        while (Math.abs(teamSimExp - teamExpPointsPred) >= TOLERANCE) {
            double midPoint = (upperMultiplier + lowerMultiplier) / 2d;
            System.out.println("Simulating for midpoint ->" + midPoint);
            teamModelOutput = simulateTeamForFgMultiplier(prePopPlayerList, midPoint);
            teamSimExp = getTeamSimExp(teamModelOutput);

            if (teamSimExp > teamExpPointsPred) {
                upperMultiplier = midPoint;
            } else {
                lowerMultiplier = midPoint;
            }
        }

        return transformToMap(teamModelOutput);
    }

    private static Map<String, PlayerModelOutput> transformToMap(List<PlayerModelOutput> list) {
        Map<String, PlayerModelOutput> map = new HashMap<>();

        for (PlayerModelOutput playerModelOutput : list) {
            map.put(playerModelOutput.getPlayerName(), playerModelOutput);
        }
        return map;
    }

    private static List<PlayerModelOutput> simulateTeamForFgMultiplier(List<PrePopPlayer> prePopPlayerList, double fgMultiplier) {
        List<PlayerModelOutput> teamModelOutput = new ArrayList<>();
//        FieldGoalNormalizer.normalize(prePopPlayerList, fgMultiplier);
        for (PrePopPlayer player : prePopPlayerList) {
            List<PlayerSimulationOutcome> playerSimulationOutcomes = simulateForFgAttemptedMultiplier(player, fgMultiplier, 40000);
            PlayerModelOutput playerModelOutput = new PlayerModelOutput(player.getName(), player.getTeam(), playerSimulationOutcomes, player.getBaseFgAttemptedPred(), fgMultiplier);
            teamModelOutput.add(playerModelOutput);
        }
        return teamModelOutput;
    }

    private static List<PrePopPlayer> prepopulatePlayers(Team team, double ownPointsExp, double oppPointsExp, double percFactor) throws PredictException {
        List<PrePopPlayer> prePopPlayerList = new ArrayList<>();
//        double teamFgExp = team.stream().filter(p->p.getCumFgAttemptedPerGame() != null). mapToDouble(p->p.getCumFgAttemptedPerGame()).sum();
        double teamFgExp = team.stream().filter(p -> p.getFgExp() != null).
                mapToDouble(p -> p.getFgExp()).sum();

        double teamAvgMinutest = team.stream().filter(p -> p.getAverageMinutes2() != null).
                mapToDouble(p -> p.getAverageMinutes2()).sum();

        double teamFtExp = team.stream().filter(p -> p.getFtExp() != null).mapToDouble(p -> p.getFtExp()).sum();

        for (Player player : team) {
            prePopPlayerList.add(new PrePopPlayer(player, ownPointsExp, oppPointsExp, teamFgExp, teamFtExp, teamAvgMinutest, percFactor));
        }
        return prePopPlayerList;
    }

    public static List<PlayerSimulationOutcome> simulateForFgAttemptedMultiplier(PrePopPlayer player, double fgMultiplier, int numbSimulations) {
        List<PlayerSimulationOutcome> list = new ArrayList<>();
//        double fgAttemptedExp = fgMultiplier * Math.round(100 * player.getBaseFgAttemptedPred())/100d;
        double fgAttemptedExpContrained = Math.max(MIN_FG_EXP, Math.min(MAX_FG_EXP, player.getBaseFgAttemptedPred() ));

        FgDistribution fgDistribution = FgDistributionModel.findOptimalDistribution(fgAttemptedExpContrained);

        Double[] probs = fgDistribution.getProbs();
        for (int i = 0; i < numbSimulations; i++) {
            int fgAttempted = simulateFgAttempted(probs);
            list.add(simulateForFgAttempted(player, Math.min(40, fgAttempted), fgMultiplier));
        }
        return list;
    }


    public static PlayerSimulationOutcome simulateForFgAttempted(PrePopPlayer player, int fgAttempted, double fgMultiplier) {
        double threePropOfShots = player.getThreePropOfShots()[fgAttempted];
        int numbOfThrees = simuNumbThrees(fgAttempted, threePropOfShots);
        double twoPerc = fgAttempted > 0 ? player.getTwoPercGivenFgs(fgAttempted, numbOfThrees) : 0;
        double threePerc = fgAttempted > 0 ? player.getThreePercGivenFgs(fgAttempted, numbOfThrees) : 0;

        twoPerc = twoPerc +  1.5 * fgMultiplier;
        threePerc = threePerc + 2 * fgMultiplier;

        double setOfFtsPred = player.getSetOfFtsPred()[fgAttempted];

        int setOfFts = getPoisson(setOfFtsPred);
        double extraFtProb = player.getExtraFtPred(fgAttempted, setOfFts);
        double ftPercPred = player.getFtPercPred(fgAttempted, setOfFts);

        return PlayerSimulator.simulateForPlayer(fgAttempted - numbOfThrees, numbOfThrees, twoPerc, threePerc, setOfFts, extraFtProb, ftPercPred);
    }

    private static int simuNumbThrees(int fgAttempted, double threePropOfShots) {
        int threeAttempted = 0;
        for (int i = 1; i <= fgAttempted; i++) {
            if (RANDOM.nextDouble() < threePropOfShots) {
                threeAttempted++;
            }
        }
        return threeAttempted;
    }

    public static int getPoisson(double lambda) {
        double L = Math.exp(-lambda);
        double p = 1.0;
        int k = 0;

        do {
            k++;
            p *= Math.random();
        } while (p > L);

        return k - 1;
    }

    public static int simulateFgAttempted(Double[] probs) {
        double rand = Math.random();
        for (int i = 0; i < probs.length; i++) {
            if (rand < probs[i]) {
                return i;
            }
            rand -= probs[i];
        }
        return probs.length - 1;
    }

    private static double getTeamSimExp(List<PlayerModelOutput> list) {
        return list.stream().mapToDouble(p -> p.getPointsAvg()).sum();
    }
}
