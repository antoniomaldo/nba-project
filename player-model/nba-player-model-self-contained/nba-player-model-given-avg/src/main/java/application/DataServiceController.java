package application;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import application.dto.NbaGameEventDto;
import application.dto.PlayerRequest;
import org.apache.commons.math3.util.Pair;
import org.joda.time.DateTime;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import sbr.domain.MatchWithOdds;
import sbr.scraper.NbaScraper;

@Controller
public class DataServiceController {

    public static final Map<String, NbaGameEventDto> EVENTS_CACHE = new HashMap<>();
    public static final Comparator<PlayerRequest> PLAYER_REQUEST_COMPARATOR = (o1, o2) -> {
        if (o1.getPmin() == null) {
            return Double.compare(o2.getAverageMinutes(), o1.getAverageMinutes());
        } else {
            return Double.compare(o2.getPmin(), o1.getPmin());
        }
    };
    public static String dataLastUpdated = null;
    public static String linesLastUpdated = null;

    private static final Map<String, String> MAPPINGS = getMappings();
    private static List<PlayerRequest> CSV_PLAYERS = new ArrayList<>();

    @ResponseBody
    @GetMapping(value = "/getDayEvents")
    public ResponseEntity<?> getDayEvents() {
        if(EVENTS_CACHE.keySet().size() == 0) {


            if (EVENTS_CACHE.isEmpty()) {
                loadDayEventsFromCsv();
            }

            List<MatchWithOdds> matchWithOddsList = NbaScraper.scrapeTodaysMatchesForBet365();
            if (matchWithOddsList.size() == 0) {
                matchWithOddsList = NbaScraper.scrapeTodaysMatchesForWilliamHill();
            }

            matchWithOddsList.sort(Comparator.comparing(MatchWithOdds::getDateTime));

            for (MatchWithOdds matchWithOdds : matchWithOddsList) {
                String homeTeam = MAPPINGS.get(matchWithOdds.getMatchWithoutOdds().getHomeTeamName());
                String awayTeam = MAPPINGS.get(matchWithOdds.getMatchWithoutOdds().getAwayTeamName());

                String eventName = awayTeam + " @ " + homeTeam;

                List<PlayerRequest> homePlayers = CSV_PLAYERS.stream().filter(p -> p.getTeam().equalsIgnoreCase(homeTeam)).collect(Collectors.toList());
                List<PlayerRequest> awayPlayers = CSV_PLAYERS.stream().filter(p -> p.getTeam().equalsIgnoreCase(awayTeam)).collect(Collectors.toList());


                Double totalPoints = matchWithOdds.getMatchTotal() == null ? null : (matchWithOdds.getMatchTotal().getLine());
                Double matchSpread = matchWithOdds.getMatchSpread() == null ? null : (matchWithOdds.getMatchSpread().getLine());

                homePlayers = homePlayers.stream().map(p -> addOddsAndTeam(p, totalPoints, matchSpread, true)).sorted(PLAYER_REQUEST_COMPARATOR).collect(Collectors.toList());
                awayPlayers = awayPlayers.stream().map(p -> addOddsAndTeam(p, totalPoints, matchSpread, false)).sorted(PLAYER_REQUEST_COMPARATOR).collect(Collectors.toList());

                NbaGameEventDto event = NbaGameEventDto.builder().
                        eventTime(matchWithOdds.getMatchWithoutOdds().getDateTime().toString()).
                        eventName(eventName).
                        homeTeamName(homeTeam).
                        awayTeamName(awayTeam).
                        totalPoints(totalPoints).
                        matchSpread(matchSpread).
                        homePlayers(homePlayers).
                        awayPlayers(awayPlayers).
                        build();
                EVENTS_CACHE.put(eventName, event);
            }
        }

        return new ResponseEntity<>(new Pair<>(DateTime.now().toLocalDateTime().toString(), EVENTS_CACHE), HttpStatus.OK);
    }

    private PlayerRequest addOddsAndTeam(PlayerRequest p, Double totalPoints, Double matchSpread, boolean isHomeTeam) {
        return p.toBuilder().totalPoints(totalPoints).matchSpread(matchSpread).isHomePlayer(isHomeTeam).build();
    }

    @ResponseBody
    @GetMapping(value = "/updateData")
    public ResponseEntity<?> updateData() {
        EVENTS_CACHE.clear();
        loadDayEventsFromCsv();
        return new ResponseEntity<>(new Pair<>(dataLastUpdated, EVENTS_CACHE), HttpStatus.OK);
    }

    @ResponseBody
    @GetMapping(value = "/updateFdPreds")
    public ResponseEntity<?> updateFdPreds() throws IOException {
        Runtime.getRuntime().exec("Rscript \"C:\\Users\\aostios\\Documents\\Basketball Model\\NBA Model\\Players New\\build java data\\Build java data.Rexec\"");
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @ResponseBody
    @PostMapping(value = "/submitLines")
    public ResponseEntity<?> submitLines(@RequestBody Map<String, NbaGameEventDto> nbaGameEventDtos) {

        for (String eventName : nbaGameEventDtos.keySet()) {
            NbaGameEventDto submittedEvent = nbaGameEventDtos.get(eventName);
            NbaGameEventDto nbaGameEventDto = EVENTS_CACHE.get(eventName);
            EVENTS_CACHE.put(eventName, nbaGameEventDto.toBuilder().
                    matchSpread(submittedEvent.getMatchSpread()).
                    totalPoints(submittedEvent.getTotalPoints()).
                    build());
        }
        linesLastUpdated = new DateTime().toLocalDateTime().toString();

        return new ResponseEntity<>(new Pair<>(EVENTS_CACHE, linesLastUpdated), HttpStatus.OK);
    }

    @ResponseBody
    @GetMapping(value = "/scrapeLines")
    public ResponseEntity<?> scrapeLines() {
        if(EVENTS_CACHE.keySet().size() == 0) {


            List<MatchWithOdds> matchWithOdds = NbaScraper.scrapeTodaysMatchesForWilliamHill();
            if (matchWithOdds.size() == 0) {
                matchWithOdds = NbaScraper.scrapeTodaysMatchesForWilliamHill();
                if (matchWithOdds.size() == 0) {
                    matchWithOdds = NbaScraper.scrapeTodaysMatchesForWilliamHill();
                }
            }

            matchWithOdds.sort(Comparator.comparing(MatchWithOdds::getDateTime));

            for (MatchWithOdds match : matchWithOdds) {
                String awayTeamName = match.getMatchWithoutOdds().getAwayTeamName();
                String homeTeamName = match.getMatchWithoutOdds().getHomeTeamName();

                String eventName = MAPPINGS.get(awayTeamName) + " @ " + MAPPINGS.get(homeTeamName);
                for (String event : EVENTS_CACHE.keySet()) {
                    if (event.equalsIgnoreCase(eventName)) {
                        NbaGameEventDto nbaGameEventDto = EVENTS_CACHE.get(event);
                        Double totalMatch = match.getMatchTotal() != null ? match.getMatchTotal().getLine() : null;
                        Double totalSpread = match.getMatchSpread() != null ? match.getMatchSpread().getLine() : null;
                        EVENTS_CACHE.put(event, nbaGameEventDto.toBuilder().eventTime(match.getDateTime().toLocalDateTime().toString()).matchSpread(totalSpread).totalPoints(totalMatch).build());
                    }
                }
            }

            linesLastUpdated = new DateTime().toLocalDateTime().toString();
        }
        return new ResponseEntity<>(new Pair<>(EVENTS_CACHE, linesLastUpdated), HttpStatus.OK);
    }

    private static Map<String, String> getMappings() {
        Map<String, String> map = new HashMap<>();

        map.put("Utah", "UTA");
        map.put("New Orleans", "NOP");
        map.put("L.A. Clippers", "LAC");
        map.put("L.A. Lakers", "LAL");
        map.put("Orlando", "ORL");
        map.put("Brooklyn", "BKN");
        map.put("Memphis", "MEM");
        map.put("Portland", "POR");
        map.put("Phoenix", "PHO");
        map.put("Washington", "WAS");
        map.put("Boston", "BOS");
        map.put("Milwaukee", "MIL");
        map.put("Sacramento", "SAC");
        map.put("San Antonio", "SAS");
        map.put("Houston", "HOU");
        map.put("Dallas", "DAL");
        map.put("Denver", "DEN");
        map.put("Oklahoma City", "OKC");
        map.put("Philadelphia", "PHI");
        map.put("Toronto", "TOR");
        map.put("Miami", "MIA");
        map.put("Indiana", "IND");
        map.put("Chicago", "CHI");
        map.put("Cleveland", "CLE");
        map.put("Minnesota", "MIN");
        map.put("Charlotte", "CHA");
        map.put("Detroit", "DET");
        map.put("Atlanta", "ATL");
        map.put("New York", "NYK");
        map.put("Golden State", "GSW");

        return map;
    }

    private void loadDayEventsFromCsv() {
        Pair<String, List<PlayerRequest>> csv = DataLoader.load();
        List<PlayerRequest> players = csv.getSecond();

        CSV_PLAYERS = players;
//        List<String> homeTeams = players.stream().filter(PlayerRequest::getIsHomePlayer).map(PlayerRequest::getTeam).distinct().collect(Collectors.toList());
//        for (String homeTeam : homeTeams) {
//            PlayerRequest homePlayer = players.stream().filter(p -> p.getTeam().equalsIgnoreCase(homeTeam)).findFirst().get();
//            String awayTeam = homePlayer.getOpp().replace("@ ", "");
//            Double totalPoints = homePlayer.getTotalPoints();
//            Double matchSpread = homePlayer.getMatchSpread();
//
//            String eventName = awayTeam + " @ " + homeTeam;
//
//            NbaGameEventDto event = NbaGameEventDto.builder().
//                    eventTime(null).
//                    eventName(eventName).
//                    homeTeamName(homeTeam).
//                    awayTeamName(awayTeam).
//                    totalPoints(totalPoints).
//                    matchSpread(matchSpread).
//                    homePlayers(players.stream().filter(p -> p.getTeam().equalsIgnoreCase(homeTeam)).sorted(PLAYER_REQUEST_COMPARATOR).collect(Collectors.toList())).
//                    awayPlayers(players.stream().filter(p -> p.getTeam().equalsIgnoreCase(awayTeam)).sorted(PLAYER_REQUEST_COMPARATOR).collect(Collectors.toList())).
//                    build();
//
//            dataLastUpdated = csv.getFirst();
//            EVENTS_CACHE.put(eventName, event);
//        }
    }

}
