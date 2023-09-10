package backtest;

import application.dto.PlayerRequest;
import org.apache.commons.math3.util.Pair;
import org.joda.time.DateTime;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CodingErrorAction;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LoadDataForGameId {

    public static List<PlayerRequest> load(String gameIdPath) {
        List<PlayerRequest> players = new ArrayList<>();
        DateTime timeStamp = DateTime.now();

        FileInputStream input = null;
        try {
            String today = DateTime.now().toLocalDate().toString();
            input = new FileInputStream(new File(gameIdPath));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        CharsetDecoder decoder = Charset.forName("UTF-8").newDecoder();
        decoder.onMalformedInput(CodingErrorAction.IGNORE);
        InputStreamReader reader = new InputStreamReader(input, decoder);
        //        BufferedReader bufferedReader = new BufferedReader( reader );

        try (BufferedReader br = new BufferedReader(reader)) {
            String line;
            String[] columns = br.readLine().split(",");
            Map<String, Integer> columnIndex = populateColumnIndexMap(columns);
            while ((line = br.readLine()) != null) {
                String[] attributes = line.split(",");

                String name = attributes[columnIndex.get("Name")].replace("\"", "");
                String team = attributes[columnIndex.get("Team")].replace("\"", "");
                String opp = "";// attributes[columnIndex.get("opp")].replace("\"", "");

                String position = attributes[columnIndex.get("Position")].replace("\"", "");
                String homeTeam = attributes[columnIndex.get("HomeTeam")].replace("\"", "");

                boolean isHomePlayer = homeTeam.equalsIgnoreCase(team);

                Double pmin = getDouble(attributes, columnIndex, "pmin");
                Double averageMinutes = getDouble(attributes, columnIndex, "averageMinutes");
                Double cumPercAttemptedPerMinute = getDouble(attributes, columnIndex, "cumPercAttemptedPerMinute");
                Double lastYeartwoPerc = getDouble(attributes, columnIndex, "lastYeartwoPerc");
                Double cumTwoPerc = getDouble(attributes, columnIndex, "cumTwoPerc");
                Double lastYearThreePerc = getDouble(attributes, columnIndex, "lastYearThreePerc");
                Double cumThreePerc = getDouble(attributes, columnIndex, "cumThreePerc");
                Double lastYearThreeProp = getDouble(attributes, columnIndex, "lastYearThreeProp");
                Double cumThreeProp = getDouble(attributes, columnIndex, "cumThreeProp");
                Double cumFtMadePerFgAttempted = getDouble(attributes, columnIndex, "cumFtMadePerFgAttempted");
                Double lastYearFtPerc = getDouble(attributes, columnIndex, "lastYearFtPerc");
                Double cumFtPerc = getDouble(attributes, columnIndex, "cumFtPerc");

                Double lastYearSetOfFtsPerFg = getDouble(attributes, columnIndex, "lastYearSetOfFtsPerFg");
                Double cumSetOfFtsPerFgAttempted = getDouble(attributes, columnIndex, "cumSetOfFtsPerFgAttempted");
                Double lastYearExtraProb = getDouble(attributes, columnIndex, "lastYearExtraProb");
                Double cumExtraProb = getDouble(attributes, columnIndex, "cumExtraProb");
                Double lastGameAttemptedPerMin = getDouble(attributes, columnIndex, "lastGameAttemptedPerMin");
                Double cumFgAttemptedPerGame = getDouble(attributes, columnIndex, "cumFgAttemptedPerGame");
                Double lastYearFgAttemptedPerGame = getDouble(attributes, columnIndex, "lastYearFgAttemptedPerGame");

                Double totals = getDouble(attributes, columnIndex, "totalPoints");
                Double matchSpread = getDouble(attributes, columnIndex, "matchSpread");
                Double cumMin = getDouble(attributes, columnIndex, "cumMin");
                Double cumFTAttempted = getDouble(attributes, columnIndex, "cumFTAttempted");


                Double LastYearFTAttempted= getDouble(attributes, columnIndex, "LastYearFTAttempted");
                Double LastYearNumbGames= getDouble(attributes, columnIndex, "LastYearNumbGames");
                Double gamesPlayedSeason= getDouble(attributes, columnIndex, "gamesPlayedSeason");

                timeStamp = timeStamp == null ? getTimeStamp(attributes, columnIndex) : timeStamp;

                players.add(PlayerRequest.builder().
                        name(name).
                        team(team).
                        opp(opp).
                        isStarter(0).
                        position(position).
                        pmin(pmin).
                        lastYearThreeProp(lastYearThreeProp).
                        cumThreeProp(cumThreeProp).
                        matchSpread(matchSpread).
                        totalPoints(totals).
                        isHomePlayer(isHomePlayer).
                        averageMinutes(averageMinutes).
                        cumPercAttemptedPerMinute(cumPercAttemptedPerMinute).
                        lastYearTwoPerc(lastYeartwoPerc).
                        cumTwoPerc(cumTwoPerc).
                        lastYearThreePerc(lastYearThreePerc).
                        cumThreePerc(cumThreePerc).
                        cumFtMadePerFgAttempted(cumFtMadePerFgAttempted).
                        lastYearFtPerc(lastYearFtPerc).
                        cumFtPerc(cumFtPerc).
                        cumFgAttemptedPerGame(cumFgAttemptedPerGame).
                        lastYearSetOfFtsPerFg(lastYearSetOfFtsPerFg).
                        cumSetOfFtsPerFgAttempted(cumSetOfFtsPerFgAttempted).
                        lastYearExtraProb(lastYearExtraProb).
                        lastGameAttemptedPerMin(lastGameAttemptedPerMin).
                        cumExtraProb(cumExtraProb).
                        lastYearFgAttemptedPerGame(lastYearFgAttemptedPerGame).
                        cumMin(cumMin).
                        cumFTAttempted(cumFTAttempted).
                                lastYearFTAttempted(LastYearFTAttempted).
                                lastYearNumbGames(LastYearNumbGames).
                                gamesPlayedSeason(gamesPlayedSeason).
                        build());
            }
        } catch (IOException ioe) {
            //        } catch (IOException ioe) {
            ioe.printStackTrace();
        }

        return players;
    }

    private static DateTime getTimeStamp(String[] attributes, Map<String, Integer> columnIndex) {
        long millis = Math.round(getDouble(attributes, columnIndex, "timestamp"));

        return new DateTime(millis * 1000);
    }

    private static Double getDouble(String[] attributes, Map<String, Integer> columnIndex, String averageMinutes) {
        Integer indexValue = columnIndex.get(averageMinutes);
        if(indexValue == null){
            return null;
        }
        String value = attributes[columnIndex.get(averageMinutes)];
        if (value.contains("NA") || value.contains("Inf")) {
            return null;
        } else {
            return Double.parseDouble(value);
        }
    }

    private static Map<String, Integer> populateColumnIndexMap(String[] columns) {
        Map<String, Integer> map = new HashMap<>();
        for (int i = 0; i < columns.length; i++) {
            map.put(columns[i].replace("\"", ""), i);
        }
        return map;
    }
}
