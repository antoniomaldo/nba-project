package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.*;

public class ThreePropModelNewTest {

    public static final double DELTA = 0.00001d;

    @Test
    public void test() throws PredictException {
        ThreePropModelNew MODEL = new ThreePropModelNew();

        Assert.assertEquals(0.0100382445664115d, MODEL.getThreePropOfShots(0.0206489675516224, 0.0111111111111111, 3, 0.606741573033708, 0d, 113.25, 4.69609272935609), DELTA);
    }}