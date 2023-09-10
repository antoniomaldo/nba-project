package domain.simulator;

import application.DataLoader;
import application.dto.PlayerRequest;
import domain.Player;
import domain.Team;
import hex.genmodel.easy.exception.PredictException;
import org.apache.commons.math3.util.Pair;
import org.joda.time.DateTime;
import org.junit.Test;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class TeamSimulatorTest {
//
//    @Test
//    public void name() throws PredictException {
//        Pair<String, List<PlayerRequest>> load = DataLoader.load();
//
//        Team team = new Team(load.getSecond().stream().filter(p->p.getTeam().equalsIgnoreCase("CLE")).map(this::toPlayer).collect(Collectors.toList()));
//
//        DateTime now = DateTime.now();
//        Map<String, PlayerModelOutput> playerModelOutputs = TeamSimulator.simulateForTeam(team, 105.75, 113.25);
//        long time = DateTime.now().minus(now.getMillis()).getMillis();
//
//        System.out.println("Time " + time + " ->" + playerModelOutputs.keySet().stream().mapToDouble(p->playerModelOutputs.get(p).getPointsAvg()).sum());
//    }
//
//
//    private Player toPlayer(PlayerRequest playerRequest) {
//        return new Player(playerRequest.getName(),
//                playerRequest.getTeam(),
//                playerRequest.getIsStarter(),
//                playerRequest.getPosition(),
//                playerRequest.getPmin(),
//                playerRequest.getLastYearThreeProp(),
//                playerRequest.getCumThreeProp(),
//                playerRequest.getCumTwoPerc(),
//                playerRequest.getCumThreePerc(),
//                playerRequest.getLastYearTwoPerc(),
//                playerRequest.getAverageMinutes(),
//                playerRequest.getCumPercAttemptedPerMinute(),
//                playerRequest.getLastYearThreePerc(),
//                playerRequest.getCumFtMadePerFgAttempted(),
//                playerRequest.getLastYearSetOfFtsPerFg(),
//                playerRequest.getCumSetOfFtsPerFgAttempted(),
//                playerRequest.getLastYearExtraProb(),
//                playerRequest.getCumExtraProb(),
//                playerRequest.getCumFtPerc(),
//                playerRequest.getLastGameAttemptedPerMin(),
//                playerRequest.getCumFgAttemptedPerGame(),
//                playerRequest.getLastYearFgAttemptedPerGame(),
//                playerRequest.getLastYearFtPerc(),
//                playerRequest.getCumMin(),
//                playerRequest.getCumFTAttempted(),
//                playerRequest.getCumFTAttemptedPerGame(),
//                playerRequest.getLastYearFTAttemptedPerGame());
//
//    }
}
