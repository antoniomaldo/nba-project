package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Assert;
import org.junit.Test;

public class FgAttemptedModelTest {
    private final static double DELTA = 0.00001;

    @Test
    public void name() throws PredictException {
        FgAttemptedModel fgAttemptedModel = new FgAttemptedModel();
        Assert.assertEquals(7.840304,
                fgAttemptedModel.getFgAttemptedRInputs(
                        18,
                        116.00,
                        11.384615,
                        null,
                        117.50,
                        11.384615,
                        0.4133520), DELTA);


        Assert.assertEquals(5.105626,
                fgAttemptedModel.getFgAttemptedRInputs(
                        15.0,
                        110.00,
                        6.3571429,
                        0.3852814,
                        102.00,
                        5.959184,
                        0.3809182
                ), DELTA);

        Assert.assertEquals(20.552509,
                fgAttemptedModel.getFgAttemptedRInputs(
                        34.0,
                        119.25,
                        21.900000,
                        0.6134454,
                        115.25,
                        21.8035714,
                        0.4223109

                ), DELTA);
    }
}