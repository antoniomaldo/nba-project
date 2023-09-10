package domain.simulator.prepopulated;

import domain.Player;
import domain.models.playerpoints.ThreePropModelNew;
import domain.simulator.TeamSimulator;
import hex.genmodel.easy.exception.PredictException;
import org.apache.commons.math3.util.Pair;

import java.util.HashMap;
import java.util.Map;

import static domain.simulator.PlayerSimulator.*;

//Pre populated player
public class PrePopPlayer {

    private final String name;
    private final String team;

    private final double baseFgAttemptedPred;

    private final double[] threePropOfShots = new double[41];
    private final double[] setOfFtsPred = new double[41];

    private final FgPercentagesGivenFgs fgPercentagesGivenFgs;
    private final Map<Pair<Integer, Integer>, Double> extraFtPreds = new HashMap<>();
    private final Map<Pair<Integer, Integer>, Double> ftPercPreds = new HashMap<>();

    private double normFgAttempted;
    public PrePopPlayer(Player player, double ownExpPoints, double oppExpPoints, double teamFgExp, double teamFtExp, double teamAvgMinutest, double percFactor) throws PredictException {
        this.name = player.getName();
        this.team = player.getTeam();
        this.baseFgAttemptedPred = FG_ATTEMPTED_MODEL.getFgAttempted(ownExpPoints, oppExpPoints, player.getPmin(), player.getAverageMinutes(), player.getLastYearFgAttemptedPerGame(), player.getCumFgAttemptedPerGame() == null ? player.getLastYearFgAttemptedPerGame() : player.getCumFgAttemptedPerGame(), teamFgExp, teamAvgMinutest);

        for (int fgAttempted = 0; fgAttempted <= 40; fgAttempted++) {
            this.threePropOfShots[fgAttempted] = THREE_PROP_MODEL_NEW.getThreePropOfShots(player.getLastYearThreeProp(), player.getCumThreeProp(), fgAttempted, player.getCumTwoPerc(), player.getCumThreePerc(), ownExpPoints, this.baseFgAttemptedPred);
            this.setOfFtsPred[fgAttempted] = fgAttempted > 0 ? SET_OF_FTS_MODEL.getSetOfFtsPred(player.getCumFtMadePerFgAttempted(), player.getLastYearSetOfFtsPerFg(), player.getCumSetOfFtsPerFgAttempted(), fgAttempted, player.getPmin(), ownExpPoints, player.getFtExp(),teamFtExp) : SET_OF_FTS_MODEL_ZERO_FG.getSetOfFtsPred(player.getCumFtMadePerFgAttempted(), player.getLastYearSetOfFtsPerFg(), player.getCumSetOfFtsPerFgAttempted(), player.getPmin(), ownExpPoints );
            for (int setOfFts = 0; setOfFts <= 20; setOfFts++) {
                double extraFtProb = EXTRA_FT_MODEL.getExtraFtProb(setOfFts, player.getLastYearExtraProb(), player.getCumExtraProb(), fgAttempted, player.getPmin());
                this.extraFtPreds.put(new Pair<>(fgAttempted, setOfFts), extraFtProb);

                double ftPercPred = FT_PERC_MODEL.getFtPerc(player.getCumFtMadePerFgAttempted(), player.getLastYearSetOfFtsPerFg(), player.getCumSetOfFtsPerFgAttempted(), fgAttempted, player.getPmin(), player.getLastYearFtPerc(), player.getCumFtPerc(), setOfFts);
                ftPercPreds.put(new Pair<>(fgAttempted, setOfFts), ftPercPred);
            }
        }


        this.fgPercentagesGivenFgs = new FgPercentagesGivenFgs(player, ownExpPoints, oppExpPoints, percFactor);

        setNormalizeFgAttempted(this.baseFgAttemptedPred);
    }

    public String getName() {
        return name;
    }

    public String getTeam() {
        return team;
    }

    public double getBaseFgAttemptedPred() {
        return baseFgAttemptedPred;
    }

    public double[] getThreePropOfShots() {
        return threePropOfShots;
    }

    public double[] getSetOfFtsPred() {
        return setOfFtsPred;
    }


    public Double getTwoPercGivenFgs(int fgAttempted, int threeAttempted) {
        return fgPercentagesGivenFgs.getTwoPercGivenFgs(Math.min(40, fgAttempted), Math.min(40,threeAttempted));
    }

    public Double getThreePercGivenFgs(int fgAttempted, int threeAttempted) {
        return fgPercentagesGivenFgs.getThreePercGivenFgs(Math.min(40, fgAttempted), Math.min(40,threeAttempted));
    }

    public Double getExtraFtPred(int fgAttempted, int setOfFts) {
        return extraFtPreds.get(new Pair<>(Math.min(40, fgAttempted), Math.min(20, setOfFts)));
    }


    public Double getFtPercPred(int fgAttempted, int setOfFts) {
        return ftPercPreds.get(new Pair<>(Math.min(40, fgAttempted), Math.min(20, setOfFts)));
    }

    public void setNormalizeFgAttempted(double normFgAttempted) {
        this.normFgAttempted = normFgAttempted;
    }

    public double getNormFgAttempted() {
        return normFgAttempted;
    }
}
