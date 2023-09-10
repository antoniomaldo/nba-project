package application.dto;

import java.util.List;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;

@AutoValue
@JsonDeserialize(builder = AutoValue_GameRequest.Builder.class)
public abstract class GameRequest {

    public static GameRequest.Builder builder() {
        return new AutoValue_GameRequest.Builder();
    }

    public abstract GameRequest.Builder toBuilder();

    public abstract List<PlayerRequest> getHomePlayers();
    public abstract List<PlayerRequest> getAwayPlayers();

    public abstract double getTotalPoints();

    public abstract double getMatchSpread();

    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public static abstract class Builder {

        public abstract GameRequest.Builder homePlayers(final List<PlayerRequest> homePlayers);
        public abstract GameRequest.Builder awayPlayers(final List<PlayerRequest> awayPlayers);
        public abstract GameRequest.Builder totalPoints(final double totalPoints);
        public abstract GameRequest.Builder matchSpread(final double matchSpread);

        public abstract GameRequest build();
    }
}
