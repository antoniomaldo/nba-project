package domain.models.playerpoints;

import org.apache.commons.math3.util.FastMath;

public class MissingPointsExpModel {

    public static final double PLAYERS_MISSING_COEF = 0.868103d;
    public static final double PLAYERS_MISSING_SQUARED_COEF = -0.084200d;
    public static final double PLAYERS_MISSING_INTERACTION_EXP_DIFF_COEF = 0.046006d;
    public static final double PLAYERS_MISSING_INTERACTION_OVER_TEN_EXP_DIFF_COEF = -0.060312d;


    public static double missingPointsPred(int missingPlayers, double expDiff) {
        return PLAYERS_MISSING_COEF * missingPlayers + //
                PLAYERS_MISSING_SQUARED_COEF * missingPlayers * missingPlayers +//
                PLAYERS_MISSING_INTERACTION_EXP_DIFF_COEF * missingPlayers * expDiff + //
                PLAYERS_MISSING_INTERACTION_OVER_TEN_EXP_DIFF_COEF * missingPlayers * FastMath.max(expDiff - 10, 0);
    }
}
