package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Assert;
import org.junit.Test;

public class FgAttemptedModelTest {
    private final static double DELTA = 0.00001;

    @Test
    public void name() throws PredictException {
        FgAttemptedModel fgAttemptedModel = new FgAttemptedModel();
//        Assert.assertEquals(6.86198952195695d, fgAttemptedModel.getFgAttempted(104.25,118.25,19,17.4666666666667,4.87931034482759,5.71428571428571,72.6949161949162,189.385714285714,"2019") , DELTA);
        double fgAttempted = fgAttemptedModel.getFgAttempted(
                104.25, //ownExpPoints
                118.25, //oppExpPoints
                5.8, //pmin
                36.8, //averageMinutes
                10.5, //Last year FGA per game
                12.4, //Cum FGA per game
                70.5, //teamFgExp
                241.1, //team average min
                "2022");

        System.out.println(fgAttempted);//23.69




    }
}
