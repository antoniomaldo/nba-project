package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.*;

public class ThreePointsPercModelNewTest {

    public static final double DELTA = 0.00001d;

    @Test
    public void test() throws PredictException {
        ThreePointsPercModelNew MODEL = new ThreePointsPercModelNew();

        Assert.assertEquals(0.269993575771658d, MODEL.getThreePointsPercentage(100.25,106.75,2,2,0.311258278145695,1.1,0.358395989974937,0.00383168563079028) , DELTA);}}