package domain.simulator.fgdistribution;

import org.apache.commons.math3.util.FastMath;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class FgDistributionModel {

    private static final List<FgDistribution> FG_DISTRIBUTION_MODEL = readCsv();

    public static final List<FgDistribution> getFgDistribution(){
        return FG_DISTRIBUTION_MODEL;
    }

    public static FgDistribution findOptimalDistribution(double average){
        double minimum = 100d;
        FgDistribution chosenDist = null;
        for(FgDistribution fgDistribution : FG_DISTRIBUTION_MODEL){
            double distMean = fgDistribution.getDistMean();
            double distance = FastMath.abs(average - distMean);
            if(distance < minimum){
                minimum = distance;
                chosenDist = fgDistribution;
            }
        }
        return chosenDist;
    }

    private static List<FgDistribution> readCsv() {
        List<FgDistribution> fgDistList = new ArrayList<>();

        InputStream resourceAsStream = FgDistributionModel.class.getResourceAsStream("/fgAttDist.csv");

        BufferedReader reader = new BufferedReader(new InputStreamReader(resourceAsStream, StandardCharsets.US_ASCII));

        try (BufferedReader br = reader) {
            String line;
            br.readLine();
            while ((line = br.readLine()) != null) {
                String[] attributes = line.split(",");

                double avg = Double.parseDouble(attributes[1]);
                String[] fgDistString = Arrays.copyOfRange(attributes, 2, 53);

                Double[] fgDist = Arrays.stream(fgDistString).map(Double::parseDouble).toArray(Double[]::new);

                FgDistribution fgDistribution = new FgDistribution(avg, fgDist);
                fgDistList.add(fgDistribution);
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        fgDistList.sort(Comparator.comparingDouble(FgDistribution::getFgExp));
        return fgDistList;
    }
}
