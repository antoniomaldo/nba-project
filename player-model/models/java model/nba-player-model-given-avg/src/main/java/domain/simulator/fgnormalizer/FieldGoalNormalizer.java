package domain.simulator.fgnormalizer;

import domain.Player;
import domain.Team;
import domain.simulator.prepopulated.PrePopPlayer;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FieldGoalNormalizer {

    private static final double FG_ATTEMPTED_MORE_TEN_COEF = 0.004574184;
    private static final double FG_ATTEMTED_LESS_TWO_COEF = 0.048600605;
    private static final double TO_ADD_INTERACTION_LOW_PREDICTION = 0.002416979;

    public static void normalize(List<PrePopPlayer> team, double totalFgAttempted) {
        Map<String, Double> playersCoef = new HashMap<>();
        setNormPreds(playersCoef, team, totalFgAttempted);
    }

    private static void setNormPreds(Map<String, Double> playersCoef, List<PrePopPlayer> team, double totalFgAttempted) {
        double allPred = 0;
        double toAdd = totalFgAttempted - team.stream().mapToDouble(p->p.getBaseFgAttemptedPred()).sum();
        for (PrePopPlayer player : team) {
            double fgAttemptedForPlayer = player.getBaseFgAttemptedPred();
            double linearPred = FG_ATTEMPTED_MORE_TEN_COEF * Math.max(10, fgAttemptedForPlayer) + //
                    FG_ATTEMTED_LESS_TWO_COEF * Math.min(2, fgAttemptedForPlayer) +
                    TO_ADD_INTERACTION_LOW_PREDICTION * Math.max(toAdd - 5, 0) * Math.max(0, 5 - fgAttemptedForPlayer);
            ;

            double predFoPlayer = Math.exp(linearPred) * fgAttemptedForPlayer;
            playersCoef.put(player.getName(), predFoPlayer);
            allPred += predFoPlayer;
        }

        for (PrePopPlayer player : team) {
            Double predForPlayer = playersCoef.get(player.getName());
            player.setNormalizeFgAttempted(predForPlayer * totalFgAttempted / allPred);
        }
    }
}
