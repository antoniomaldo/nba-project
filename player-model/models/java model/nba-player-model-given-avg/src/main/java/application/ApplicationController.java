package application;

import static application.DataServiceController.EVENTS_CACHE;
import static org.springframework.http.HttpStatus.OK;
import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import application.dto.NbaGameEventDto;
import application.dto.PlayerRequest;
import application.dto.PlayerRequestList;
import domain.NbaGameEvent;
import domain.Player;
import domain.Team;
import domain.simulator.*;
import hex.genmodel.easy.exception.PredictException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class ApplicationController {

    public static final NbaPointsModel NBA_POINTS_MODEL = new NbaPointsModel();
//    public static final PlayerSimulator PLAYER_SIMULATOR = new PlayerSimulator();
//
    private static final Map<String, PlayerModelOutput> CACHED_RESULTS = new HashMap<>();
//
//    @ResponseBody
//    @GetMapping(value = "getCachedPlayerPredictions")
//    public ResponseEntity<?> getCachedPlayerPredictions() throws PredictException {
//        return new ResponseEntity<>(CACHED_RESULTS, OK);
//    }

//    @ResponseBody
//    @PostMapping(value = "generateForTickedPlayers", consumes = APPLICATION_JSON_VALUE, produces = APPLICATION_JSON_VALUE)
//    public ResponseEntity<?> generateForTickedPlayers(@RequestBody PlayerRequestList players) throws PredictException {
//        for (PlayerRequest playerRequest : players.getPlayers()) {
//            try {
//                getPlayerPrediction(playerRequest);
//            } catch (Exception e) {
//
//            }
//        }
//        return new ResponseEntity<>(CACHED_RESULTS, OK);
//    }

//    @ResponseBody
//    @PostMapping(value = "getPlayerPrediction", consumes = APPLICATION_JSON_VALUE, produces = APPLICATION_JSON_VALUE)
//    public ResponseEntity<?> getPlayerPrediction(@RequestBody PlayerRequest playerRequest) throws PredictException {
//        Boolean isHomePlayer = playerRequest.getIsHomePlayer();
//        double ownExpPoints = isHomePlayer ? (playerRequest.getTotalPoints() - playerRequest.getMatchSpread())  2 : (playerRequest.getTotalPoints() + playerRequest.getMatchSpread())  2;
//        double oppExpPoints = playerRequest.getTotalPoints() - ownExpPoints;
//
//        PlayerModelOutput playerModelOutput = PlayerSimulator.simulatePlayer(toPlayer(playerRequest), ownExpPoints, oppExpPoints, 40000, playerRequest.getTargetAverage());
//
//        CACHED_RESULTS.put(playerRequest.getTeam() + "-" + playerRequest.getName(), playerModelOutput);
//
//        return new ResponseEntity<>(playerModelOutput, OK);
//    }

    @ResponseBody
    @PostMapping(value = "getMatchPredictions", consumes = APPLICATION_JSON_VALUE, produces = APPLICATION_JSON_VALUE)
    public ResponseEntity<?> getGamePred(@RequestBody NbaGameEventDto gameRequest) throws PredictException {

        List<Player> homePlayers = toPlayerList(gameRequest.getHomePlayers(), "home");
        List<Player> awayPlayers = toPlayerList(gameRequest.getAwayPlayers(), "away");
        if (gameRequest.getMatchSpread() != null && gameRequest.getTotalPoints() != null) {

            double matchSpread = gameRequest.getMatchSpread();
            double totalPoints = gameRequest.getTotalPoints();

            NbaGameEvent nbaGameEvent = new NbaGameEvent(totalPoints, matchSpread, new Team(homePlayers), new Team(awayPlayers));
            Map<String, PlayerModelOutput> modelOutput = NBA_POINTS_MODEL.runModel(nbaGameEvent);

            for (String playerName : modelOutput.keySet()) {
                PlayerModelOutput playerModelOutput = modelOutput.get(playerName);
                CACHED_RESULTS.put(playerModelOutput.getPlayerTeam() + "-" + playerModelOutput.getPlayerName(), modelOutput.get(playerName));
            }
        }
        return new ResponseEntity<>(CACHED_RESULTS, HttpStatus.OK);
    }
//
    @ResponseBody
    @GetMapping(value = "runAllGames")
    public ResponseEntity<?> runAllGames() {
        for (String eventName : EVENTS_CACHE.keySet()) {
            try {
                System.out.println("Running " + eventName);
                getGamePred(EVENTS_CACHE.get(eventName));
            } catch (Exception e) {
                System.out.println("Error running " + eventName);
            }
        }

        return new ResponseEntity<>(CACHED_RESULTS, HttpStatus.OK);
    }

    private List<Player> toPlayerList(List<PlayerRequest> playerRequestList, String team) {
        List<Player> list = new ArrayList<>();
        for (PlayerRequest playerRequest : playerRequestList) {
            list.add(toPlayer(playerRequest));
        }
        return list;
    }

    private Player toPlayer(PlayerRequest playerRequest) {
        System.out.println(playerRequest.getName());
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
                playerRequest.getCumExtraProb(),
                playerRequest.getCumFtPerc(),
                playerRequest.getLastGameAttemptedPerMin(),
                playerRequest.getCumFgAttemptedPerGame(),
                playerRequest.getLastYearFgAttemptedPerGame(),
                playerRequest.getLastYearFtPerc(),
                playerRequest.getCumMin(),
                playerRequest.getCumFTAttempted(),
                playerRequest.getLastYearFTAttempted(),
                playerRequest.getLastYearNumbGames(),
                playerRequest.getGamesPlayedSeason());
    }

}
