package domain;

public class NbaGameEvent {

    private final double totalPoints;
    private final double matchSpread;
    private final Team homeTeam;
    private final Team awayTeam;

    public NbaGameEvent(double totalPoints, double matchSpread, Team homeTeam, Team awayTeam) {
        this.totalPoints = totalPoints;
        this.matchSpread = matchSpread;
        this.homeTeam = homeTeam;
        this.awayTeam = awayTeam;
    }

    public double getTotalPoints() {
        return totalPoints;
    }

    public double getMatchSpread() {
        return matchSpread;
    }

    public Team getHomeTeam() {
        return homeTeam;
    }

    public Team getAwayTeam() {
        return awayTeam;
    }
}

