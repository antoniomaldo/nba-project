package domain.simulator.prepopulated;

import domain.Player;
import domain.simulator.PlayerSimulator;
import hex.genmodel.easy.exception.PredictException;
import org.apache.commons.math3.util.Pair;

import java.util.HashMap;
import java.util.Map;

public class FgPercentagesGivenFgs {

    private final Map<Pair<Integer, Integer>, Double> twoPercGivenFgs = new HashMap<>();
    private final Map<Pair<Integer, Integer>, Double> threePercGivenFgs = new HashMap<>();

    public FgPercentagesGivenFgs(Player player, double ownPointsExp, double oppPointsExp, double percFactor) throws PredictException {
        for (int fgAttempted = 1; fgAttempted <= 40; fgAttempted++) {
            for (int threeAttempted = 0; threeAttempted <= fgAttempted; threeAttempted++) {
                double twoPerc = PlayerSimulator.TWO_POINTS_PERC_MODEL_NEW.getTwoPointsPercentage(ownPointsExp, oppPointsExp, player.getLastYearTwoPerc(), player.getPmin(), player.getCumTwoPerc(), player.getCumPercAttemptedPerMinute(), fgAttempted - threeAttempted, fgAttempted);
                double threePerc = PlayerSimulator.THREE_POINTS_PERC_MODEL_NEW.getThreePointsPercentage(ownPointsExp, oppPointsExp, threeAttempted, fgAttempted, player.getLastYearThreePerc(), player.getPmin(), player.getCumThreePerc(), player.getCumPercAttemptedPerMinute());
                twoPerc = twoPerc + percFactor;
                threePerc = threePerc + percFactor;
                this.twoPercGivenFgs.put(new Pair<>(fgAttempted, threeAttempted), twoPerc);
                this.threePercGivenFgs.put(new Pair<>(fgAttempted, threeAttempted), threePerc);
            }
        }
    }

    public Double getTwoPercGivenFgs(int fgAttempted, int threeAttempted) {
        return twoPercGivenFgs.get(new Pair<>(fgAttempted, threeAttempted));
    }

    public Double getThreePercGivenFgs(int fgAttempted, int threeAttempted) {
        return threePercGivenFgs.get(new Pair<>(fgAttempted, threeAttempted));
    }
}


