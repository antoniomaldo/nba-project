package application.dto;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;
import com.sun.istack.Nullable;

@AutoValue
@JsonDeserialize(builder = AutoValue_PlayerRequest.Builder.class)
public abstract class PlayerRequest {
    public static PlayerRequest.Builder builder() {
        return new AutoValue_PlayerRequest.Builder();
    }

    public abstract PlayerRequest.Builder toBuilder();

    public abstract String getName();

    public abstract String getTeam();


    public abstract String getOpp();


    public abstract int getIsStarter();

    public abstract String getPosition();

    @Nullable
    public abstract Double getPmin();

    @Nullable
    public abstract Double getLastYearThreeProp();

    @Nullable
    public abstract Double getCumThreeProp();

    @Nullable
    public abstract Double getCumTwoPerc();

    @Nullable
    public abstract Double getCumThreePerc();

    @Nullable
    public abstract Double getTotalPoints();

    @Nullable
    public abstract Double getMatchSpread();

    @Nullable
    public abstract Double getLastYearTwoPerc();

    @Nullable
    public abstract Double getAverageMinutes();

    @Nullable
    public abstract Double getCumPercAttemptedPerMinute();

    @Nullable
    public abstract Double getLastYearThreePerc();

    @Nullable
    public abstract Double getCumFtMadePerFgAttempted();

    @Nullable
    public abstract Boolean getIsHomePlayer();


    @Nullable
    public abstract Double getLastYearSetOfFtsPerFg();

    @Nullable
    public abstract Double getCumSetOfFtsPerFgAttempted();

    @Nullable
    public abstract Double getLastYearExtraProb();

    @Nullable
    public abstract Double getCumExtraProb();

    @Nullable
    public abstract Double getLastGameAttemptedPerMin();

    @Nullable
    public abstract Double getLastYearFtPerc();

    @Nullable
    public abstract Double getCumFtPerc();

    @Nullable
    public abstract Double getCumFgAttemptedPerGame();

    @Nullable
    public abstract Double getTargetAverage();

    @Nullable
    public abstract Double getLastYearFgAttemptedPerGame();

    @Nullable
    public abstract Double getCumMin();
    @Nullable
    public abstract Double getCumFTAttempted();

    @Nullable
    public abstract Double getCumFTAttemptedPerGame();
    @Nullable
    public abstract Double getLastYearFTAttemptedPerGame();
    @Nullable
    public abstract Double getLastYearFTAttempted();
    @Nullable
    public abstract Double getLastYearNumbGames();
    @Nullable
    public abstract Double getGamesPlayedSeason();


    @Nullable
    public abstract Boolean getGeneratePrices();

    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public static abstract class Builder {

        public abstract Builder name(final String name);

        public abstract Builder team(final String team);


        public abstract Builder opp(final String opp);


        public abstract Builder isStarter(final int isStarter);

        public abstract Builder position(final String position);

        public abstract Builder pmin(final Double pmin);

        public abstract Builder lastYearThreeProp(final Double lastYearThreeProp);

        public abstract Builder cumThreeProp(final Double cumThreeProp);

        public abstract Builder cumTwoPerc(final Double cumTwoPerc);

        public abstract Builder cumThreePerc(final Double cumThreePerc);

        public abstract Builder totalPoints(final Double totalPoints);

        public abstract Builder matchSpread(final Double matchSpread);

        public abstract Builder lastYearTwoPerc(final Double lastYearTwoPerc);

        public abstract Builder averageMinutes(final Double averageMinutes);

        public abstract Builder cumPercAttemptedPerMinute(final Double cumPercAttemptedPerMinute);

        public abstract Builder lastYearThreePerc(final Double lastYearThreePerc);

        public abstract Builder cumFtMadePerFgAttempted(final Double cumFtMadePerFgAttempted);

        public abstract Builder isHomePlayer(final Boolean isHomePlayer);

        public abstract Builder lastYearSetOfFtsPerFg(final Double lastYearSetOfFtsPerFg);

        public abstract Builder cumSetOfFtsPerFgAttempted(final Double cumSetOfFtsPerFgAttempted);

        public abstract Builder lastYearExtraProb(final Double lastYearExtraProb);

        public abstract Builder cumExtraProb(final Double cumExtraProb);

        public abstract Builder lastGameAttemptedPerMin(final Double lastGameAttemptedPerMin);

        public abstract Builder lastYearFtPerc(final Double lastYearFtPerc);

        public abstract Builder cumFtPerc(final Double cumFtPerc);
        public abstract Builder cumFgAttemptedPerGame(final Double cumFgAttemptedPerGame);

        public abstract Builder targetAverage(final Double targetAverage);

        public abstract Builder generatePrices(final Boolean generatePrices);

        public abstract Builder cumMin(final Double cumMin);
        public abstract Builder cumFTAttempted(final Double cumFTAttempted);

        public abstract Builder lastYearFgAttemptedPerGame(final Double lastYearFgAttemptedPerGame);
        public abstract Builder cumFTAttemptedPerGame(final Double cumFTAttemptedPerGame);
        public abstract Builder lastYearFTAttemptedPerGame(final Double lastYearFTAttemptedPerGame);

        public abstract Builder lastYearFTAttempted(final Double lastYearFTAttempted);
        public abstract Builder lastYearNumbGames(final Double lastYearNumbGames);
        public abstract Builder gamesPlayedSeason(final Double gamesPlayedSeason);


        public abstract PlayerRequest build();
    }

}

