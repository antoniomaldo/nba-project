package domain;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Team implements Iterable<Player> {

    private final List<Player> players;
    private final List<Player> playersToBeExcludedFromNorm;
    private final int teamGameNumber;

    public Team(List<Player> players, int teamGameNumber) {
        this.players = players;
        this.playersToBeExcludedFromNorm = new ArrayList<>();
        this.teamGameNumber = 1;
    }

    public Team(List<Player> players) {
        this.players = players;
        this.playersToBeExcludedFromNorm = new ArrayList<>();
        this.teamGameNumber = 1;
    }

    public Team(List<Player> players, List<String> playersToExcluded) {
        this.players = players;
        this.playersToBeExcludedFromNorm = getPlayersWithNames(playersToExcluded);
        this.teamGameNumber = 1;
    }

    public List<Player> getPlayers() {
        return players;
    }

    public List<Player> getPlayersToBeExcludedFromNorm() {
        return this.playersToBeExcludedFromNorm;
    }

    public List<Player> getPlayersWithNames(List<String> playerNames) {
        return this.players.stream().filter(p -> playerNames.contains(p.getName())).collect(Collectors.toList());
    }

    public Player getPlayerWithName(String playerName) {
        return this.players.stream().filter(p -> playerName.equalsIgnoreCase(p.getName())).findFirst().get();
    }

    public List<Player> getStarters() {
        return this.players.stream().filter(p -> p.getIsStarter() == 1).collect(Collectors.toList());
    }

    public Stream<Player> stream() {
        return this.players.stream();
    }

    @Override
    public Iterator<Player> iterator() {
        return this.players.iterator();
    }

    public int getTeamGameNumber() {
        return this.teamGameNumber;
    }
}
