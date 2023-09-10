package sbr.scraper.props;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;

@AutoValue
@JsonDeserialize(builder = GameView.Builder.class)
public abstract class GameView {
    public static Builder builder() {
        return new AutoValue_GameView.Builder();
    }

//    public abstract GameView getGameView();
//    @Nullable
    public abstract ViewData getViewdata();

    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public abstract static class Builder {

        @JsonCreator
        private static Builder create() {
            return GameView.builder();
        }

        public abstract Builder viewdata(ViewData viewdata);

        public abstract GameView build();
    }
}
