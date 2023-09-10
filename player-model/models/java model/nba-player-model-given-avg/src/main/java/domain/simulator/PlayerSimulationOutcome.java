package domain.simulator;

public class PlayerSimulationOutcome {
    private final int points;
    private final int twoPointers;
    private final int twoPointersAttempted;
    private final int threePointers;
    private final int threePointersAttempted;
    private final int ftScored;
    private final int ftAttempted;
    private final int zeroFtAttempted;
    private final int zeroFgAttempted;

    public PlayerSimulationOutcome(int points, int twoPointers, int twoPointersAttempted, int threePointers, int threePointersAttempted, int ftScored, int ftAttempted, int zeroFgAttempted, int zeroFtAttempted) {
        this.points = points;
        this.twoPointers = twoPointers;
        this.twoPointersAttempted = twoPointersAttempted;
        this.threePointers = threePointers;
        this.threePointersAttempted = threePointersAttempted;
        this.ftScored = ftScored;
        this.ftAttempted = ftAttempted;
        this.zeroFgAttempted = zeroFgAttempted;
        this.zeroFtAttempted = zeroFtAttempted;
    }

    public int getPoints() {
        return points;
    }

    public int getThreePointers() {
        return threePointers;
    }

    public int getFtScored() {
        return ftScored;
    }

    public int getTwoPointers() {
        return twoPointers;
    }

    public int getTwoPointersAttempted() {
        return twoPointersAttempted;
    }

    public int getThreePointersAttempted() {
        return threePointersAttempted;
    }

    public int getFtAttempted() {
        return ftAttempted;
    }

    public int getZeroFtAttempted() {
        return zeroFtAttempted;
    }

    public int getZeroFgAttempted() {
        return zeroFgAttempted;
    }
}
