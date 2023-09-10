package domain.simulator.fgattemptedcalibration;

import static org.junit.Assert.*;

import org.junit.Test;

public class FgAttemptedModelGivenResid2Test {

    @Test
    public void name() {
        System.out.println(FgAttemptedModelGivenResid2.getPrediction(5, 50, -20));
        System.out.println(FgAttemptedModelGivenResid2.getPrediction(10, 50, 20));
        System.out.println(FgAttemptedModelGivenResid2.getPrediction(10, 500, 20));
        System.out.println(FgAttemptedModelGivenResid2.getPrediction(10, 500, 0));
    }
}
