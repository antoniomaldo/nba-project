package domain.simulator.fgnormalizer;

import org.apache.commons.math3.util.FastMath;

import java.util.HashMap;
import java.util.Map;

public class FieldGoalNormalizerGIvenPointsDiff {

    private static final double POS_POINTS_DIFF_INTERACTION_FG = -0.0040948;
    private static final double NEG_POINTS_DIFF_INTERACTION_FG = -0.0007783;

    public static double normalize(double fieldGoalExp, double pointsDiff) {
        Map<String, Double> playersCoef = new HashMap<>();

        double pred = FastMath.max(0, pointsDiff) * FastMath.max(0, 10 - fieldGoalExp)* POS_POINTS_DIFF_INTERACTION_FG  + //
                FastMath.min(0, pointsDiff)* FastMath.max(0, 10 - fieldGoalExp) * NEG_POINTS_DIFF_INTERACTION_FG;

       return  fieldGoalExp * (pred + 1);
    }

}
