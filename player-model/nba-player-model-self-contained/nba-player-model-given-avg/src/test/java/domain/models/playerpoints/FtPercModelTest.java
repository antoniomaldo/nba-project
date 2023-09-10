package domain.models.playerpoints;

import hex.genmodel.easy.exception.PredictException;
import org.junit.Test;

import static org.junit.Assert.*;

public class FtPercModelTest {

    @Test
    public void name() throws PredictException {
        FtPercModel ftPercModel = new FtPercModel();

        double ftPerc = ftPercModel.getFtPerc(0.8, 2d, 0.85, 20d, 15d, 0.95, 0.95,10);
        System.out.println(ftPerc);
    }
}