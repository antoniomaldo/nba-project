package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.*;

public class TwoPointsPercModelNewTest {

    public static final double DELTA = 0.0001d;

    @Test
    public void test() throws PredictException {
        TwoPointsPercModelNew MODEL = new TwoPointsPercModelNew();

        Assert.assertEquals(0.659024962290699d, MODEL.getTwoPointsPercentage(113,110.5,0.627345844504021,1,0.638225255972696,0.00195126316567644,6,6) , DELTA);    }



}