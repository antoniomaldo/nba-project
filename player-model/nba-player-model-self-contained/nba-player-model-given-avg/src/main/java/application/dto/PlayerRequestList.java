package application.dto;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;
import com.sun.istack.Nullable;

import java.util.List;

@AutoValue
@JsonDeserialize(builder = AutoValue_PlayerRequestList.Builder.class)
public abstract class PlayerRequestList {
    public static PlayerRequestList.Builder builder() {
        return new AutoValue_PlayerRequestList.Builder();
    }

    public abstract PlayerRequestList.Builder toBuilder();

    public abstract List<PlayerRequest> getPlayers();


    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public static abstract class Builder {

        public abstract Builder players(final List<PlayerRequest> players);

        public abstract PlayerRequestList build();
    }

}

