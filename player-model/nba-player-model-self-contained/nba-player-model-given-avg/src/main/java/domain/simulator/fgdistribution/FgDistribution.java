package domain.simulator.fgdistribution;

public class FgDistribution {
    private final double fgExp;
    private final Double[] probs;
    private final double distMean;

    public FgDistribution(double fgExp, Double[] probs) {
        this.fgExp = fgExp;
        this.probs = probs;
        this.distMean = getDistMean(probs);
    }

    public double getFgExp() {
        return fgExp;
    }

    public Double[] getProbs() {
        return probs;
    }

    public double getDistMean(){
        return this.distMean;
    }
    private double getDistMean(Double[] probs){
        double mean=0;
        for (int i = 0; i < probs.length; i++) {
            mean += i * probs[i];
        }
        return mean;
    }
}
