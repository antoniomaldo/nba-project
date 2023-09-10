package domain.simulator.fgdistribution;

import org.junit.Test;

import java.util.List;
import java.util.stream.Stream;

import static org.junit.Assert.*;

public class FgDistributionModelTest {

    @Test
    public void name() {
        List<FgDistribution> fgDistribution = FgDistributionModel.getFgDistribution();

        for (double j = 1.5; j < 25; j+=0.05) {
            double finalJ = Math.round(100 * j) / 100d;
            FgDistribution fgDistributionForExp = fgDistribution.stream().filter(p -> p.getFgExp() == finalJ).findFirst().get();

            double avg = 0;
            for (int i = 0; i < fgDistributionForExp.getProbs().length; i++) {
                avg+= i * fgDistributionForExp.getProbs()[i];
            }
            System.out.println(j + " - " + avg);
        }

    }
}