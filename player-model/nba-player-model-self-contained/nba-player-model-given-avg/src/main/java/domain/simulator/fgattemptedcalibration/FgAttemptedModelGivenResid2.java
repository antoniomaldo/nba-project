package domain.simulator.fgattemptedcalibration;

import org.apache.commons.math3.util.FastMath;

public class FgAttemptedModelGivenResid2 {
    private static final double[] COEF = {-0.0005046669d, -0.0004811603d, -0.0008974564d, 0.0004476935d, 0.0001554229d, 0.001627387d, 0.1306486d, -0.1550291d, -0.09915498d, 0.2532573};

    public static double getPrediction(double fieldGoalAttempted, double teamTotalPred, double modelResid) {
        double percTotal = fieldGoalAttempted / teamTotalPred;
        return FastMath.exp(FastMath.log(fieldGoalAttempted) + // //
                fieldGoalAttempted * Math.max(modelResid, 0) * COEF[0] +// //
                fieldGoalAttempted * Math.min(modelResid, 0) * COEF[1] +// //
                Math.max(modelResid, 0) * Math.max(fieldGoalAttempted-15,0) * COEF[2]+ //
                Math.min(modelResid, 0) * Math.max(fieldGoalAttempted-15,0) * COEF[3]+ //
                Math.max(modelResid, 0) * Math.max(fieldGoalAttempted-10,0) * COEF[4]+ //
                Math.min(modelResid, 0) * Math.max(fieldGoalAttempted-10,0) * COEF[5]+ //
                Math.max(modelResid, 0) * Math.max(percTotal-0.15,0) * COEF[6]+ //
                Math.min(modelResid, 0) * Math.max(percTotal-0.15,0) * COEF[7]+ //
                Math.max(modelResid, 0) * Math.max(0.05 - percTotal,0) * COEF[8]+ //
                Math.min(modelResid, 0) * Math.max(0.05 - percTotal,0) * COEF[9]);
    }
}
