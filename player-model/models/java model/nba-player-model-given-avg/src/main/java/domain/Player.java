package domain;

public class Player {

    private final String name;
    private final String team;
    private final int isStarter;
    private final String position;
    private final Double pmin;

    private final Double lastYearThreeProp;
    private final Double cumThreeProp;
    private final Double cumTwoPerc;
    private final Double cumThreePerc;

    private final Double lastYearTwoPerc;

    private final Double averageMinutes;
    private final Double averageMinutes2;
    private final Double cumPercAttemptedPerMinute;
    private final Double cumFgAttemptedPerGame;
    private final Double lastYearThreePerc;
    private final Double lastGameAttemptedPerMin;

    private final Double cumFtMadePerFgAttempted;
    private final Double lastYearSetOfFtsPerFg;
    private final Double cumSetOfFtsPerFgAttempted;
    private final Double lastYearExtraProb;
    private final Double cumExtraProb;
    private final Double cumFtPerc;
    private final Double lastYearFgAttemptedPerGame;
    private final Double lastYearFtPerc;

    private final Double cumFTAttempted;
    private final Double LastYearFTAttempted;

    private final Double LastYearNumbGames;
    private final Double gamesPlayedSeason;
    private final Double ftExp;
    private final Double fgExp;


    public Player(String name, String team, int isStarter, String position, Double pmin, Double lastYearThreeProp, Double cumThreeProp, Double cumTwoPerc, Double cumThreePerc, Double lastYearTwoPerc, Double averageMinutes, Double cumPercAttemptedPerMinute, Double lastYearThreePerc, Double cumFtMadePerFgAttempted, Double lastYearSetOfFtsPerFg, Double cumSetOfFtsPerFgAttempted, Double lastYearExtraProb, Double cumExtraProb, Double cumFtPerc, Double lastGameAttemptedPerMin, Double cumFgAttemptedPerGame, Double lastYearFgAttemptedPerGame, Double lastYearFtPerc, Double cumMin, Double cumFTAttempted, Double LastYearFTAttempted, Double LastYearNumbGames, Double gamesPlayedSeason) {
        this.name = name;
        this.team = team;
        this.isStarter = isStarter;
        this.position = position;
        this.pmin = pmin;
        this.lastYearThreeProp = lastYearThreeProp;
        this.cumThreeProp = cumThreeProp;
        this.cumTwoPerc = cumTwoPerc;
        this.cumThreePerc = cumThreePerc;
        this.lastYearTwoPerc = lastYearTwoPerc;
        this.averageMinutes = averageMinutes;
        this.cumPercAttemptedPerMinute = cumPercAttemptedPerMinute;
        this.lastYearThreePerc = lastYearThreePerc;
        this.cumFtMadePerFgAttempted = cumFtMadePerFgAttempted;
        this.lastYearSetOfFtsPerFg = lastYearSetOfFtsPerFg;
        this.cumSetOfFtsPerFgAttempted = cumSetOfFtsPerFgAttempted;
        this.lastYearExtraProb = lastYearExtraProb;
        this.cumExtraProb = cumExtraProb;
        this.cumFtPerc = cumFtPerc;
        this.lastGameAttemptedPerMin = lastGameAttemptedPerMin;
        this.cumFgAttemptedPerGame = cumFgAttemptedPerGame;
        this.lastYearFgAttemptedPerGame = lastYearFgAttemptedPerGame;
        this.lastYearFtPerc = lastYearFtPerc;

        this.cumFTAttempted = cumFTAttempted;
        this.LastYearFTAttempted = LastYearFTAttempted;

        this.LastYearNumbGames = LastYearNumbGames;
        this.gamesPlayedSeason = gamesPlayedSeason;

        Double cumFTAttemptedPerGame = cumFTAttempted == null || gamesPlayedSeason == null || gamesPlayedSeason <= 1 ? null : cumFTAttempted / (gamesPlayedSeason - 1);
        Double LastYearFTAttemptedPerGame = LastYearFTAttempted == null || LastYearNumbGames == null || LastYearNumbGames == 0 ? null : LastYearFTAttempted / LastYearNumbGames;

        this.ftExp = cumFTAttemptedPerGame == null ? LastYearFTAttemptedPerGame : cumFTAttemptedPerGame;


        this.fgExp = this.cumFgAttemptedPerGame==null ? this.lastYearFgAttemptedPerGame : this.cumFgAttemptedPerGame;
        this.averageMinutes2 = this.averageMinutes == null? this.pmin: this.averageMinutes;
    }

    public String getName() {
        return name;
    }

    public String getTeam() {
        return team;
    }

    public int getIsStarter() {
        return isStarter;
    }

    public String getPosition() {
        return position;
    }

    public Double getPmin() {
        return pmin;
    }

    public Double getLastYearThreeProp() {
        return lastYearThreeProp;
    }

    public Double getCumThreeProp() {
        return cumThreeProp;
    }

    public Double getCumTwoPerc() {
        return cumTwoPerc;
    }

    public Double getCumThreePerc() {
        return cumThreePerc;
    }

    public Double getLastYearTwoPerc() {
        return lastYearTwoPerc;
    }

    public Double getAverageMinutes() {
        return averageMinutes;
    }

    public Double getCumPercAttemptedPerMinute() {
        return cumPercAttemptedPerMinute;
    }

    public Double getLastYearThreePerc() {
        return lastYearThreePerc;
    }

    public Double getCumFtMadePerFgAttempted() {
        return cumFtMadePerFgAttempted;
    }

    public Double getLastYearSetOfFtsPerFg() {
        return lastYearSetOfFtsPerFg;
    }

    public Double getCumSetOfFtsPerFgAttempted() {
        return cumSetOfFtsPerFgAttempted;
    }

    public Double getLastYearExtraProb() {
        return lastYearExtraProb;
    }

    public Double getCumExtraProb() {
        return cumExtraProb;
    }

    public Double getCumFtPerc() {
        return cumFtPerc;
    }

    public Double getLastGameAttemptedPerMin() {
        return this.lastGameAttemptedPerMin;
    }

    public Double getCumFgAttemptedPerGame() {
        return this.cumFgAttemptedPerGame;
    }

    public Double getLastYearFgAttemptedPerGame() {
        return lastYearFgAttemptedPerGame;
    }

    public Double getLastYearFtPerc() {
        return lastYearFtPerc;
    }

    public Double getFtExp(){return this.ftExp;}
    public Double getFgExp(){return this.fgExp;}

    public Double getAverageMinutes2(){return this.averageMinutes2;}
}


