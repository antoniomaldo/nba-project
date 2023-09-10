package domain.simulator.fgattemptedcalibration;

import org.junit.Test;

public class FgAttemptedModelGivenResidTest {
    @Test
    public void name() {
        double totalTarget = 30d;

        double firstExp = 10;
        double secondExp = 15;
        double thirdExp = 1;

        double firstExpCal = firstExp;
        double secondExpCal = secondExp;
        double thirdExpCal = thirdExp;

        double totalExpCal = firstExpCal + secondExpCal + thirdExpCal;

        double modelResid = 0;
        while (Math.abs(totalExpCal - totalTarget) > 0.1) {
            modelResid -= 0.01;
            firstExpCal = FgAttemptedModelGivenResid.getPrediction(firstExp, modelResid);
            secondExpCal = FgAttemptedModelGivenResid.getPrediction(secondExp, modelResid);
            thirdExpCal = FgAttemptedModelGivenResid.getPrediction(thirdExp, modelResid);
            totalExpCal = firstExpCal + secondExpCal + thirdExpCal;

            System.out.println(modelResid);
        }
        int x = 1;
    }
}
