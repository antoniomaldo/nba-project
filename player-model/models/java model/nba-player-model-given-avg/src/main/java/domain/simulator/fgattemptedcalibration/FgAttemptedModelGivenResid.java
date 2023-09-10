package domain.simulator.fgattemptedcalibration;

import org.apache.commons.math3.util.FastMath;

public class FgAttemptedModelGivenResid {
    private static final double MODEL_RESID_COEF = -3.542e-03;
    private static final double MODEL_RESID_CUBIC_COEF = -9.804e-07;


    public static double getPrediction(double fieldGoalAttempted, double modelResid){
        return FastMath.exp(
                FastMath.log(fieldGoalAttempted) + //
                        MODEL_RESID_COEF * modelResid + //
                        MODEL_RESID_CUBIC_COEF * modelResid * modelResid * modelResid);
    }
}
