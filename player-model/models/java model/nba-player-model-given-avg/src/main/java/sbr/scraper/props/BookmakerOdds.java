package sbr.scraper.props;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;

@AutoValue
@JsonDeserialize(builder = BookmakerOdds.Builder.class)
public abstract class BookmakerOdds {
    public static Builder builder() {
        return new AutoValue_BookmakerOdds.Builder();
    }

    public abstract String getSportsbook();
    public abstract ViewData getViewdata();

    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public abstract static class Builder {

        @JsonCreator
        private static Builder create() {
            return BookmakerOdds.builder();
        }
        public abstract Builder sportsbook(String sportsbook);
        public abstract Builder viewdata(ViewData viewdata);

        public abstract BookmakerOdds build();
    }
}
