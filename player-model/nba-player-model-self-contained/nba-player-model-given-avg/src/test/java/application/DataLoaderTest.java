package application;

import application.dto.PlayerRequest;
import org.apache.commons.math3.util.Pair;
import org.joda.time.DateTime;
import org.junit.Ignore;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class DataLoaderTest {

    @Test
    @Ignore
    public void name() {

        Pair<String, List<PlayerRequest>> load = DataLoader.load();
        int x =1;
    }
}
