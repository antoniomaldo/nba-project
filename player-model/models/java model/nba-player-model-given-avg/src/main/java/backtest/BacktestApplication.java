package backtest;

import application.dto.PlayerRequest;
import au.com.bytecode.opencsv.CSVWriter;
import domain.Player;
import domain.Team;
import domain.simulator.PlayerModelOutput;
import domain.simulator.TeamSimulator;
import hex.genmodel.easy.exception.PredictException;

import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

import static backtest.GetGameIdPaths.CSV_INPUT_LOCATION;

public class BacktestApplication {

    public static final String CSV_OUTPUT_LOCATION = "C:\\Users\\Antonio\\Documents\\nba-project\\player-model\\models\\backtest\\not_normalized\\";

    public static void main(String[] args) throws PredictException, IOException {
        List<String> gameIdPaths = GetGameIdPaths.get();
        int counter = 0;
        boolean shouldSimulate = false;
        for(String gameIdPath : gameIdPaths){
            counter++;
            if(Integer.parseInt(gameIdPath.replace(CSV_INPUT_LOCATION, "").replace("\\Game","").replace(".csv", "")) == 401468240){
                shouldSimulate = true;
            }
            if(shouldSimulate) {


                String gameId = gameIdPath.replace(CSV_INPUT_LOCATION, "");
                System.out.println(gameIdPath);
                List<PlayerRequest> players = LoadDataForGameId.load(gameIdPath);

                if(players != null) {
                    Double matchSpread = players.get(0).getMatchSpread();
                    Double totals = players.get(0).getTotalPoints();
                    if (matchSpread != null && totals != null) {
                        List<PlayerRequest> homePlayers = players.stream().filter(p -> p.getIsHomePlayer() & p.getPmin() != null).collect(Collectors.toList());
                        List<PlayerRequest> awayPlayers = players.stream().filter(p -> !p.getIsHomePlayer() & p.getPmin() != null).collect(Collectors.toList());

                        double homeExp = (totals - matchSpread) / 2d;
                        double awayExp = totals - homeExp;

                        Map<String, PlayerModelOutput> homeOutput = homePlayers.size() == 0 || homeExp < 50 ? new HashMap<>() : TeamSimulator.simulateForTeam(new Team(toPlayerList(homePlayers)), homeExp, awayExp);
                        Map<String, PlayerModelOutput> awayOutput = awayPlayers.size() == 0 || awayExp < 50 ? new HashMap<>() : TeamSimulator.simulateForTeam(new Team(toPlayerList(awayPlayers)), awayExp, homeExp);


                        homeOutput.putAll(awayOutput);
                        writeCsv(homeOutput, gameId);
                    }
                }
            }
        }
    }

    private static void writeCsv(Map<String, PlayerModelOutput> playerModelOutputMap, String gameId) throws IOException {
        CSVWriter writer = new CSVWriter(new FileWriter(CSV_OUTPUT_LOCATION + gameId));
        String[] header = new String[59];
        header[0] = "rowId";
        header[1] = "pointsAvg";
        header[2] = "fieldGoalAttempted";
        header[3] = "fgMultiplier";
        for (int i = 4; i < 43; i++) {
            int value = i - 4;
            header[i] = "Points_" + value + "_Prob";
        }
        for (int i = 43; i < 50; i++) {
            int value = i - 43;
            header[i] = "Threes_" + value + "_Prob";
        }
        header[50] = "averageFts";
        header[51] = "averageThrees";
        header[52] = "averageTwos";
        header[53] = "averageTwosAttempted";
        header[54] = "averageThreesAttempted";
        header[55] = "averageFtsAttempted";
        header[56] = "zeroFgProb";
        header[57] = "zeroFtProb";
        header[58] = "playProb";

        writer.writeNext(header);

        for(String key : playerModelOutputMap.keySet()){
            PlayerModelOutput playerModelOutput = playerModelOutputMap.get(key);
            String rowId = playerModelOutput.getPlayerTeam() + "-" + playerModelOutput.getPlayerName();
            double pointsAverage = playerModelOutput.getPointsAvg();

            Map<Integer, Double> pointsMap = playerModelOutput.getPointsMap();
            Map<Integer, Double> threesMap = playerModelOutput.getThreesMap();

            String[] row = new String[59];

            row[0] = rowId;
            row[1] = String.valueOf(pointsAverage);
            row[2] = String.valueOf(playerModelOutput.getFieldGoalsAttempted());
            row[3] = String.valueOf(playerModelOutput.getFgMultiplier());

            for (int i = 4; i < 43; i++) {
                int value = i - 4;
                row[i] = getProbability(pointsMap, value);
                header[i] = "Points_" + value + "_Prob";
            }
            for (int i = 43; i < 50; i++) {
                int value = i - 43;
                row[i] = getProbability(threesMap, value);
                header[i] = "Threes_" + value + "_Prob";
            }

            //average number of twos
            double averageFts = playerModelOutput.getFtsMap().keySet().stream().mapToDouble(k -> playerModelOutput.getFtsMap().get(k) * k).sum();
            double averageThrees = playerModelOutput.getThreesMap().keySet().stream().mapToDouble(k -> playerModelOutput.getThreesMap().get(k) * k).sum();
            double averageTwos = playerModelOutput.getTwosMap().keySet().stream().mapToDouble(k -> playerModelOutput.getTwosMap().get(k) * k).sum();
            double averageTwosAttempted = playerModelOutput.getTwosAttemptedMap().keySet().stream().mapToDouble(k -> playerModelOutput.getTwosAttemptedMap().get(k) * k).sum();
            double averageThreesAttempted = playerModelOutput.getThreesAttemptedMap().keySet().stream().mapToDouble(k -> playerModelOutput.getThreesAttemptedMap().get(k) * k).sum();
            double averageFtsAttempted = playerModelOutput.getFtsAttemptedMap().keySet().stream().mapToDouble(k -> playerModelOutput.getFtsAttemptedMap().get(k) * k).sum();

            row[50] = ""  + averageFts + "";
            row[51] = ""  + averageThrees + "";
            row[52] = "" + averageTwos + "";
            row[53] = "" + averageTwosAttempted + "";
            row[54] = "" + averageThreesAttempted + "";
            row[55] = "" + averageFtsAttempted + "";
            row[56] = "" + playerModelOutput.getZeroFgAttProb() + "";
            row[57] = "" + playerModelOutput.getZeroFtAttProb() + "";
            row[58] = "" + playerModelOutput.getPlayProb() + "";

            writer.writeNext(row);
        }
        writer.close();
    }

    private static String getProbability(Map<Integer, Double> valueMap, int value){
        return String.valueOf(valueMap.get(value) == null ? 0d : valueMap.get(value));
    }

    private static List<Player> toPlayerList(List<PlayerRequest> playerRequestList) {
        List<Player> list = new ArrayList<>();
        for (PlayerRequest playerRequest : playerRequestList) {
            list.add(toPlayer(playerRequest));
        }
        return list;
    }
    private static Player toPlayer(PlayerRequest playerRequest) {
        return new Player(playerRequest.getName(),
                playerRequest.getTeam(),
                playerRequest.getIsStarter(),
                playerRequest.getPosition(),
                playerRequest.getPmin(),
                playerRequest.getLastYearThreeProp(),
                playerRequest.getCumThreeProp(),
                playerRequest.getCumTwoPerc(),
                playerRequest.getCumThreePerc(),
                playerRequest.getLastYearTwoPerc(),
                playerRequest.getAverageMinutes(),
                playerRequest.getCumPercAttemptedPerMinute(),
                playerRequest.getLastYearThreePerc(),
                playerRequest.getCumFtMadePerFgAttempted(),
                playerRequest.getLastYearSetOfFtsPerFg(),
                playerRequest.getCumSetOfFtsPerFgAttempted(),
                playerRequest.getLastYearExtraProb(),
                playerRequest.getCumExtraProb(), playerRequest.getCumFtPerc(),
                playerRequest.getLastGameAttemptedPerMin(),
                playerRequest.getCumFgAttemptedPerGame(),
                playerRequest.getLastYearFgAttemptedPerGame(),
                playerRequest.getLastYearFtPerc(),
                playerRequest.getCumMin(),
                playerRequest.getCumFTAttempted(),
                playerRequest.getLastYearFTAttempted(),
                playerRequest.getLastYearNumbGames(),
                playerRequest.getGamesPlayedSeason()

                );
    }
}
