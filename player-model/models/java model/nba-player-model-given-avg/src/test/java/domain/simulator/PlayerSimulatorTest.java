package domain.simulator;

import java.util.List;

import application.DataLoader;
import application.dto.PlayerRequest;
import domain.Player;
import hex.genmodel.easy.exception.PredictException;
import org.junit.Ignore;
import org.junit.Test;

public class PlayerSimulatorTest {
//
//    @Test
//    @Ignore
//    public void name() throws PredictException {
//        List<PlayerRequest> players = DataLoader.load().getSecond();
//
//        PlayerRequest playerRequest = players.stream().filter(p -> p.getName().equalsIgnoreCase("D. DeRozan")).findFirst().get();
//
//        Player player = toPlayer(playerRequest);
//
//        PlayerModelOutput playerSimulationOutcome = PlayerSimulator.simulatePlayer(player, 120.5, 120.5, 40000, 26d);
//
//        for (int i = 0; i < 50; i++) {
//            System.out.println((i + 0.5) + " -> " +  1d / playerSimulationOutcome.getLessThanXPointsProb(i + 0.5));
//        }
//    }
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
