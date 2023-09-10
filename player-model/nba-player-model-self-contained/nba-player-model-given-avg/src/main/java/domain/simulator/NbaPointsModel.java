package domain.simulator;

import java.util.Map;

import domain.NbaGameEvent;
import hex.genmodel.easy.exception.PredictException;


public class NbaPointsModel {

    public Map<String, PlayerModelOutput> runModel(NbaGameEvent nbaGameEvent) throws PredictException {
        double matchSpread = nbaGameEvent.getMatchSpread();
        double matchTotalPoints = nbaGameEvent.getTotalPoints();

        double homeExpPoints = (matchTotalPoints - matchSpread) / 2d;
        double awayExpPoints = (matchTotalPoints + matchSpread) / 2d;

        Map<String, PlayerModelOutput> homePlayers = TeamSimulator.simulateForTeam(nbaGameEvent.getHomeTeam(), homeExpPoints, awayExpPoints);
        Map<String, PlayerModelOutput> awayPlayers = TeamSimulator.simulateForTeam(nbaGameEvent.getAwayTeam(), awayExpPoints, homeExpPoints);

        homePlayers.putAll(awayPlayers);
        return homePlayers;
    }
}
