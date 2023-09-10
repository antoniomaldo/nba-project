package domain.models.playerpoints;

import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.*;

public class MissingPointsExpModelTest {

    @Test
    public void name() {
        Assert.assertEquals(2.319529 ,MissingPointsExpModel.missingPointsPred(2, 10), 0.0001);
        Assert.assertEquals(3.820555  ,MissingPointsExpModel.missingPointsPred(5, 20), 0.0001);
        Assert.assertEquals(0.8299091 ,MissingPointsExpModel.missingPointsPred(1, 1), 0.0001);
        Assert.assertEquals(0 ,MissingPointsExpModel.missingPointsPred(0, 10), 0.0001);
    }

    @Test
    public void name2() {
        Assert.assertEquals(0 ,MissingPointsExpModel.missingPointsPred(0, 2), 0.0001);

    }
}