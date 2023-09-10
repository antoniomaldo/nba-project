package application.dto;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;
import com.google.auto.value.AutoValue;

import java.util.List;

@AutoValue
@JsonDeserialize(builder = AutoValue_WindowsPaths.Builder.class)
public abstract class WindowsPaths {

    public static WindowsPaths.Builder builder() {
        return new AutoValue_WindowsPaths.Builder();
    }
    public abstract String getBasePath();

    public abstract String getEspnDataPath();

    @AutoValue.Builder
    @JsonPOJOBuilder(withPrefix = "")
    public static abstract class Builder {

        public abstract WindowsPaths.Builder basePath(final String basePath);

        public abstract WindowsPaths.Builder espnDataPath(final String espnDataPath);

        public abstract WindowsPaths build();
    }
}
