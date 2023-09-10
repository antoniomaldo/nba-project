package backtest;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class GetGameIdPaths {

    public static final String CSV_INPUT_LOCATION = "C:\\Users\\Antonio\\Documents\\NBA\\player-model\\models\\Given points line\\backtest\\input";

    public static List<String> get(){
        File file = new File(CSV_INPUT_LOCATION);

        ArrayList<File> listFiles = new ArrayList<>(Arrays.asList(file.listFiles()));

        return listFiles.stream().map(l->l.getAbsolutePath()).collect(Collectors.toList());
    }
}
