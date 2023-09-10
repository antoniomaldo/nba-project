package domain.simulator;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

import domain.Player;
import domain.models.playerpoints.*;
import domain.simulator.fgdistribution.FgDistribution;
import domain.simulator.fgdistribution.FgDistributionModel;
import hex.genmodel.easy.exception.PredictException;

public class PlayerSimulator {
//    public static final TwoPointsPercModel TWO_POINTS_PERC_MODEL = new TwoPointsPercModel();
    public static final TwoPointsPercModelNew TWO_POINTS_PERC_MODEL_NEW = new TwoPointsPercModelNew();

//    public static final ThreePointsPercModel THREE_POINTS_PERC_MODEL = new ThreePointsPercModel();
    public static final ThreePointsPercModelNew THREE_POINTS_PERC_MODEL_NEW = new ThreePointsPercModelNew();

//    public static final ThreePropModel THREE_PROP_MODEL = new ThreePropModel();
    public static final ThreePropModelNew THREE_PROP_MODEL_NEW = new ThreePropModelNew();

    public static final FgAttemptedModel FG_ATTEMPTED_MODEL = new FgAttemptedModel();
    public static final SetOfFtsModel SET_OF_FTS_MODEL = new SetOfFtsModel();
    public static final SetOfFtsZeroFgModel SET_OF_FTS_MODEL_ZERO_FG = new SetOfFtsZeroFgModel();
    public static final ExtraFtModel EXTRA_FT_MODEL = new ExtraFtModel();
    public static final FtPercModel FT_PERC_MODEL = new FtPercModel();

    public static final Random RANDOM = new Random();

    public static final List<FgDistribution> FG_DISTRIBUTION_MODEL = FgDistributionModel.getFgDistribution();
    private static final double MIN_FG_EXP = FG_DISTRIBUTION_MODEL.stream().mapToDouble(f -> f.getFgExp()).min().getAsDouble();
    private static final double MAX_FG_EXP = FG_DISTRIBUTION_MODEL.stream().mapToDouble(f -> f.getFgExp()).max().getAsDouble();

    private static final double TOLERANCE = 0.05;

//
//
//    public static PlayerModelOutput simulatePlayer(Player player, double ownExpPoints, double oppExpPoints, int numbSimulations, Double expectedAveragePoints) throws PredictException {
//        List<Double> averages = FG_DISTRIBUTION_MODEL.stream().map(f -> f.getFgExp()).sorted().collect(Collectors.toList());
//
//        if (player.getPmin() != null) {
//
//            double fgAttempted = FG_ATTEMPTED_MODEL.getFgAttempted(ownExpPoints, oppExpPoints, player.getPmin(), player.getAverageMinutes(),  player.getLastYearFgAttemptedPerGame(),player.getCumFgAttemptedPerGame(), 0, 0);
//            fgAttempted = Math.round(100 * fgAttempted) / 100d;
//            System.out.println("Model fg attempted -> " + fgAttempted);
//            List<PlayerSimulationOutcome> playerSimulationOutcomes = simulateForOptimalFgAttempted(player, fgAttempted, ownExpPoints, oppExpPoints, numbSimulations);
//            PlayerModelOutput playerModelOutput = new PlayerModelOutput(player.getName(),player.getTeam(), playerSimulationOutcomes, fgAttempted, 1);
//
//            return playerModelOutput;
//        }
//
//        int optimaIndex = finOptimalIndex(player, expectedAveragePoints, ownExpPoints, oppExpPoints, 2 * numbSimulations, averages);
//
//        List<PlayerSimulationOutcome> playerSimulationOutcomes = simulateForOptimalFgAttempted(player, averages.get(optimaIndex), ownExpPoints, oppExpPoints, numbSimulations);
//
//        PlayerModelOutput playerModelOutput = new PlayerModelOutput(player.getName(), player.getTeam(), playerSimulationOutcomes, -1, 1);
//
//        return playerModelOutput;
//    }
//
//    private static int finOptimalIndex(Player player, double expectedPoints, double ownExpPoints, double oppExpPoints, int numbSimulations, List<Double> averages) throws PredictException {
//        double upperFg = expectedPoints;
//        double lowerFg = expectedPoints / 1.5;
//
//        upperFg = Math.max(1.5, Math.min(Math.round(upperFg * 10) / 10, 40));
//        lowerFg = Math.max(1.5, Math.min(Math.round(lowerFg * 10) / 10, 40));
//
//        int lowerIndex = (int) (100 * lowerFg - 150);
//        int upperIndex = (int) (100 * upperFg - 150);
//
//        double lowerExp = simulateForFgAttempted(player, averages.get(lowerIndex), ownExpPoints, oppExpPoints, numbSimulations);
//        double upperExp = simulateForFgAttempted(player, averages.get(upperIndex), ownExpPoints, oppExpPoints, numbSimulations);
//
//        if (Math.abs(lowerExp - expectedPoints) <= TOLERANCE) {
//            return lowerIndex;
//        } else if (Math.abs(upperExp - expectedPoints) <= TOLERANCE) {
//            return upperIndex;
//        } else if (lowerExp < expectedPoints && upperExp > expectedPoints) {
//            int midIndex = (lowerIndex + upperIndex) / 2;
//            double midExp = 1;
//            while (upperIndex - lowerIndex >= 2 && Math.abs(expectedPoints - midExp) > TOLERANCE) {
//                midIndex = (lowerIndex + upperIndex) / 2;
//                midExp = simulateForFgAttempted(player, averages.get(midIndex), ownExpPoints, oppExpPoints, numbSimulations);
//                if (Math.abs(midExp - expectedPoints) <= TOLERANCE) {
//                    return midIndex;
//                } else if (midExp == upperExp - 1 || midExp == lowerExp + 1) {
//                    return midIndex;
//                } else if (midExp > expectedPoints && upperExp > expectedPoints) {
//                    upperIndex = midIndex;
//                } else {
//                    lowerIndex = midIndex;
//                }
//            }
//            return midIndex;
//        } else {
//            lowerIndex = 0;
//            upperIndex = averages.size() - 1;
//            lowerExp = simulateForFgAttempted(player, averages.get(lowerIndex), ownExpPoints, oppExpPoints, numbSimulations);
//            upperExp = simulateForFgAttempted(player, averages.get(upperIndex), ownExpPoints, oppExpPoints, numbSimulations);
//
//            if (Math.abs(lowerExp - expectedPoints) <= TOLERANCE) {
//                return lowerIndex;
//            } else if (Math.abs(upperExp - expectedPoints) <= TOLERANCE) {
//                return upperIndex;
//            } else if (lowerExp < expectedPoints && upperExp > expectedPoints) {
//                int midIndex = (lowerIndex + upperIndex) / 2;
//                double midExp = 1;
//                while (upperIndex - lowerIndex >= 2 && Math.abs(expectedPoints - midExp) > TOLERANCE) {
//                    midIndex = (lowerIndex + upperIndex) / 2;
//                    midExp = simulateForFgAttempted(player, averages.get(midIndex), ownExpPoints, oppExpPoints, numbSimulations);
//                    if (Math.abs(midExp - expectedPoints) <= TOLERANCE) {
//                        return midIndex;
//                    } else if (midExp == upperExp - 1 || midExp == lowerExp + 1) {
//                        return midIndex;
//                    } else if (midExp > expectedPoints && upperExp > expectedPoints) {
//                        upperIndex = midIndex;
//                    } else {
//                        lowerIndex = midIndex;
//                    }
//                }
//                return midIndex;
//            } else {
//                return 1;//FIXME
//            }
//        }
//    }

    public static List<PlayerSimulationOutcome> simulateForOptimalFgAttempted(Player player, double fgAttemptedExp, double ownExpPoints, double oppExpPoints, int numbSimulations) throws PredictException {
        List<PlayerSimulationOutcome> list = new ArrayList<>();
//        System.out.println("Simulating for " + fgAttemptedExp);
        double fgAttemptedExpContrained = Math.max(MIN_FG_EXP, Math.min(MAX_FG_EXP, fgAttemptedExp));

        FgDistribution fgDistribution = FG_DISTRIBUTION_MODEL.stream().filter(f -> f.getFgExp() == fgAttemptedExpContrained).findFirst().get();
        Double[] probs = fgDistribution.getProbs();
        for (int i = 0; i < numbSimulations; i++) {
            int fgAttempted = simulateFgAttempted(probs);
            list.add(simulateForFgAttempted(player, fgAttempted, ownExpPoints, oppExpPoints, fgAttemptedExp));
        }
        return list;
    }

    public static double simulateForFgAttempted(Player player, double fgAttemptedExp, double ownExpPoints, double oppExpPoints, int numbSimulations, double fgPred) throws PredictException {
        System.out.println("Simulating for " + fgAttemptedExp);
        FgDistribution fgDistribution = FG_DISTRIBUTION_MODEL.stream().filter(f -> f.getFgExp() == fgAttemptedExp).findFirst().get();
        int points = 0;
        Double[] probs = fgDistribution.getProbs();
        for (int i = 0; i < numbSimulations; i++) {
            int fgAttempted = simulateFgAttempted(probs);
            points += simulateForFgAttempted(player, fgAttempted, ownExpPoints, oppExpPoints, fgPred).getPoints();
        }
        return (double) points / numbSimulations;
    }

    public static PlayerSimulationOutcome simulateForFgAttempted(Player player, int fgAttempted, double ownExpPoints, double oppExpPoints, double fgPred) throws PredictException {
        double threePropOfShots = THREE_PROP_MODEL_NEW.getThreePropOfShots(player.getLastYearThreeProp(), player.getCumThreeProp(), fgAttempted, player.getCumTwoPerc(), player.getCumThreePerc(), ownExpPoints, fgPred);
        int numbOfThrees = simuNumbThrees(fgAttempted, threePropOfShots);
        double twoPerc = TWO_POINTS_PERC_MODEL_NEW.getTwoPointsPercentage(ownExpPoints, oppExpPoints, player.getLastYearTwoPerc(), player.getPmin(), player.getCumTwoPerc(), player.getCumPercAttemptedPerMinute(), fgAttempted - numbOfThrees, fgAttempted);
        double threePerc = THREE_POINTS_PERC_MODEL_NEW.getThreePointsPercentage(ownExpPoints, oppExpPoints, numbOfThrees, fgAttempted, player.getLastYearThreePerc(), player.getPmin(), player.getCumThreePerc(), player.getCumPercAttemptedPerMinute());

        double setOfFtsPred = fgAttempted > 0 ? SET_OF_FTS_MODEL.getSetOfFtsPred(player.getCumFtMadePerFgAttempted(), player.getLastYearSetOfFtsPerFg(), player.getCumSetOfFtsPerFgAttempted(), fgAttempted, player.getPmin(), ownExpPoints, player.getFtExp(), 20.5) : SET_OF_FTS_MODEL_ZERO_FG.getSetOfFtsPred(player.getCumFtMadePerFgAttempted(), player.getLastYearSetOfFtsPerFg(), player.getCumSetOfFtsPerFgAttempted(), player.getPmin(), ownExpPoints);
        int setOfFts = getPoisson(setOfFtsPred);
        double extraFtProb = EXTRA_FT_MODEL.getExtraFtProb(setOfFts, player.getLastYearExtraProb(), player.getCumExtraProb(), fgAttempted, player.getPmin());

        return simulateForPlayer(fgAttempted - numbOfThrees, numbOfThrees, twoPerc, threePerc, setOfFts, extraFtProb, player.getCumFtPerc());
    }

    public static PlayerSimulationOutcome simulateForPlayer(int twoAttempted, int threeAttempted, double twoPerc, double threePerc, int setOfFt, double extraFtProb, double ftPerc) {
        int score = 0;
        int threes = 0;
        int twos = 0;
        int fts = 0;

        int extraFt = RANDOM.nextDouble() < extraFtProb ? 1 : 0;
        int numbFts = 2 * setOfFt + extraFt;

        final int threeAttemptedInitial = threeAttempted;
        final int twoAttemptedInitial = twoAttempted;
        final int ftsAttemptedInitial = numbFts;

        while (threeAttempted > 0) {
            if (RANDOM.nextDouble() < threePerc) {
                score = score + 3;
                threes = threes + 1;
            }
            threeAttempted = threeAttempted - 1;
        }

        while (twoAttempted > 0) {
            if (RANDOM.nextDouble() < twoPerc) {
                score = score + 2;
                twos++;
            }
            twoAttempted = twoAttempted - 1;
        }


        while (numbFts > 0) {
            if (RANDOM.nextDouble() < ftPerc) {
                score++;
                fts++;
            }
            numbFts--;
        }

        return new PlayerSimulationOutcome(score, twos , twoAttemptedInitial, threes, threeAttemptedInitial, fts, ftsAttemptedInitial, twoAttemptedInitial + threeAttemptedInitial == 0 ? 1:0,ftsAttemptedInitial==0?1:0);
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

}
