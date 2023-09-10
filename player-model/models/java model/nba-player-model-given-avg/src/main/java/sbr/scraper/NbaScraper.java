package sbr.scraper;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collector;
import java.util.stream.Collectors;

import org.joda.time.DateTime;
import sbr.domain.Bookmaker;
import sbr.domain.MatchWithOdds;
import sbr.domain.MatchWithoutOdds;

public class NbaScraper {

    private static final MatchesScraper<MatchWithoutOdds> MATCH_SCRAPER_BET_365 = new UpcomingMatchesScraper(Bookmaker.MATCHBOOK);
    private static final MatchesScraper<MatchWithoutOdds> MATCH_SCRAPER_PINNACLE = new UpcomingMatchesScraper(Bookmaker.MATCHBOOK);
    private static final MatchesScraper<MatchWithoutOdds> MATCH_SCRAPER_MATCHBOOK = new UpcomingMatchesScraper(Bookmaker.MATCHBOOK);

    public static List<MatchWithOdds> scrapeTodaysMatchesForWilliamHill() {
        return scrapeTodaysMatchesForBookmaker("williamhill");
    }
    public static List<MatchWithOdds> scrapeTodaysMatchesFor888() {
        return scrapeTodaysMatchesForBookmaker("888sport");
    }
    public static List<MatchWithOdds> scrapeTodaysMatchesForBetWay() {
        return scrapeTodaysMatchesForBookmaker("betway");
    }
    private static List<MatchWithOdds> scrapeTodaysMatchesForBookmaker(String bookmakerName) {
        try {
            String todayUrl = "https://www.sportsbookreview.com/betting-odds/nba-basketball/";
            System.out.println(todayUrl);
            String todayDate = DateTime.now().toLocalDate().toString().replace("-", "");
            List<Map<String, MatchWithOdds>> matches = MATCH_SCRAPER_BET_365.getMatches(
                    todayUrl, "?date=" + todayDate);


            return matches.stream().map(m -> m.get(bookmakerName))
                    .filter(m->m!=null)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}
