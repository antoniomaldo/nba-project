package domain.simulator;

import org.apache.commons.math3.distribution.BinomialDistribution;

import java.util.Random;

public class FtModel {

    public static int simulateFreeThrows(double expftPoints, double oddProb, double ftPerc) {
        int ceiling = (int) Math.ceil(expftPoints / ftPerc);
        int odd = ceiling % 2 == 0 ? ceiling + 1 : ceiling;
        int even = odd + 1;
        double noProb = 1 - expftPoints / (oddProb * odd * ftPerc + (1 - oddProb) * even * ftPerc);
        double random = Math.random();

        if (random < noProb) {
            return 0;
        } else if (Math.random() < oddProb) {
            return odd - getBinomial(odd, 1 - ftPerc);
        } else {
            return even - getBinomial(even, 1 - ftPerc);
        }
    }

    public static int getBinomial(int n, double p) {
        double log_q = Math.log(1.0 - p);
        int x = 0;
        double sum = 0;
        for (; ; ) {
            sum += Math.log(Math.random()) / (n - x);
            if (sum < log_q) {
                return x;
            }
            x++;
        }
    }
}
