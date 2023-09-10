package sbr.scraper;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;


import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import sbr.domain.Market;
import sbr.domain.MatchWithOdds;
import sbr.domain.MatchWithoutOdds;
import sbr.scraper.props.BookmakerOdds;
import sbr.scraper.props.GameRow;
import sbr.scraper.props.ScriptObject;

public abstract class MatchesScraper<T extends MatchWithoutOdds> {

    protected abstract ScriptObject getMarkets(String url) throws IOException;

    public  List<Map<String, MatchWithOdds>> getMatches(String baseUrl, String appendToUrl) throws IOException {
        List<MatchWithOdds> matches = new ArrayList<>();

//        appendToUrl = "?date=20220423";

        ScriptObject matchSpreadMap = getMarkets(baseUrl  + appendToUrl);
//        ScriptObject firstHalfSpreadMap = getMarkets(baseUrl + spreadPrefix + "1st-half/" + appendToUrl, false, sport == Sport.BASKETBALL);
        ScriptObject matchTotalMap = getMarkets(baseUrl + "totals/" + appendToUrl);
//        ScriptObject firstHalfTotalMap = getMarkets(baseUrl + "totals/1st-half/" + appendToUrl, false, sport == Sport.BASKETBALL);
        ScriptObject moneyLineMap = getMarkets(baseUrl + "money-line/full-game/" + appendToUrl);

        List<GameRow> spreadGameRows = matchSpreadMap.getProps().getPageProps().getOddsTables().get(0).getOddsTableModel().getGameRows();
//        List<GameRow> fhSpreadGameRows = firstHalfSpreadMap.getProps().getPageProps().getOddsTables().get(0).getOddsTableModel().getGameRows();
        List<GameRow> totalsGameRows = matchTotalMap.getProps().getPageProps().getOddsTables().get(0).getOddsTableModel().getGameRows();
//        List<GameRow> fhTotalsGameRows = firstHalfTotalMap.getProps().getPageProps().getOddsTables().get(0).getOddsTableModel().getGameRows();
        List<GameRow> moneyLineGameRows = moneyLineMap.getProps().getPageProps().getOddsTables().get(0).getOddsTableModel().getGameRows();

        List<Map<String, MatchWithOdds>> list = new ArrayList<>();
        for (int i = 0; i < spreadGameRows.size(); i++) {
            GameRow spreadGameRow = spreadGameRows.get(i);
//            GameRow fhSpreadGameRow = fhSpreadGameRows.get(i);
            GameRow totalGameRow = totalsGameRows.get(i);
//            GameRow fhTotalGameRow = fhTotalsGameRows.get(i);
            GameRow moneyLineGameRow = moneyLineGameRows.get(i);

            List<String> bookmakers = spreadGameRow.getOddsViews().stream().filter(Objects::nonNull).map(BookmakerOdds::getSportsbook).collect(Collectors.toList());

            Map<String, MatchWithOdds> bookmakerOddsMap = new HashMap<>();
            for (String bookmaker : bookmakers) {
                Optional<BookmakerOdds> spreadOdds = spreadGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
//                Optional<BookmakerOdds> fhSpreadOdds = fhSpreadGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
                Optional<BookmakerOdds> totalOdds = totalGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
//                Optional<BookmakerOdds> fhTotalOdds = fhTotalGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
                Optional<BookmakerOdds> moneyLineOdds = moneyLineGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();

                Double matchSpread = null;
                Double homeOdds = null;
                Double awayOdds = null;
                Double totalPoints = null;
                Double overOdds = null;
                Double underOdds = null;
                Double homeMoneyLineOdds = null;
                Double awayMoneyLineOdds = null;

                String homeTeam = null;
                String awayTeam = null;
                String startDate = null;
                if (spreadOdds.isPresent()) {
                    homeTeam = spreadGameRows.get(i).getGameView().getViewdata().getHomeTeam().get("DisplayName");
                    awayTeam = spreadGameRows.get(i).getGameView().getViewdata().getAwayTeam().get("DisplayName");
                    startDate = spreadGameRows.get(i).getGameView().getViewdata().getStartDate();
                    Map<String, Double> currentLines = spreadOdds.get().getViewdata().getCurrentLine();
                    homeOdds = convertAmericanOdds(currentLines.get("HomeOdds"));
                    awayOdds = convertAmericanOdds(currentLines.get("AwayOdds"));
                    matchSpread = currentLines.get("HomeSpread");
                }
                if(totalOdds.isPresent()){
                    Map<String, Double> currentLines = totalOdds.get().getViewdata().getCurrentLine();
                    totalPoints = currentLines.get("Total");
                    overOdds = convertAmericanOdds(currentLines.get("OverOdds"));
                    underOdds = convertAmericanOdds(currentLines.get("UnderOdds"));
                }
                if(moneyLineOdds.isPresent()){
                    Map<String, Double> currentLines = moneyLineOdds.get().getViewdata().getCurrentLine();
                    homeMoneyLineOdds = convertAmericanOdds(currentLines.get("HomeOdds"));
                    awayMoneyLineOdds = convertAmericanOdds(currentLines.get("AwayOdds"));
                }

                MatchWithoutOdds matchWithoutOdds = new MatchWithoutOdds(new DateTime(startDate), awayTeam, homeTeam);
                if(matchSpread != null && totalPoints != null && awayMoneyLineOdds != null) {

                    bookmakerOddsMap.put(bookmaker, new MatchWithOdds(matchWithoutOdds,
                            new Market(matchSpread, awayOdds, homeOdds),
                            new Market(totalPoints, overOdds, underOdds)
                    ));
                }
            }
            list.add(bookmakerOddsMap);
            bookmakerOddsMap = new HashMap<>();
            for (String bookmaker : bookmakers) {
                Optional<BookmakerOdds> spreadOdds = spreadGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
//                Optional<BookmakerOdds> fhSpreadOdds = fhSpreadGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
                Optional<BookmakerOdds> totalOdds = totalGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
//                Optional<BookmakerOdds> fhTotalOdds = fhTotalGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();
                Optional<BookmakerOdds> moneyLineOdds = moneyLineGameRow.getOddsViews().stream().filter(j -> j != null && j.getSportsbook().equalsIgnoreCase(bookmaker)).findFirst();

                Double matchSpread = null;
                Double homeOdds = null;
                Double awayOdds = null;
                Double totalPoints = null;
                Double overOdds = null;
                Double underOdds = null;
                Double homeMoneyLineOdds = null;
                Double awayMoneyLineOdds = null;

                String homeTeam = null;
                String awayTeam = null;
                String startDate = null;
                if (spreadOdds.isPresent()) {
                    homeTeam = spreadGameRows.get(i).getGameView().getViewdata().getHomeTeam().get("DisplayName");
                    awayTeam = spreadGameRows.get(i).getGameView().getViewdata().getAwayTeam().get("DisplayName");
                    startDate = spreadGameRows.get(i).getGameView().getViewdata().getStartDate();
                    Map<String, Double> currentLines = spreadOdds.get().getViewdata().getOpeningLine();
                    homeOdds = convertAmericanOdds(currentLines.get("HomeOdds"));
                    awayOdds = convertAmericanOdds(currentLines.get("AwayOdds"));
                    matchSpread = currentLines.get("HomeSpread");
                }
                if(totalOdds.isPresent()){
                    Map<String, Double> currentLines = totalOdds.get().getViewdata().getOpeningLine();
                    totalPoints = currentLines.get("Total");
                    overOdds = convertAmericanOdds(currentLines.get("OverOdds"));
                    underOdds = convertAmericanOdds(currentLines.get("UnderOdds"));
                }
                if(moneyLineOdds.isPresent()){
                    Map<String, Double> currentLines = moneyLineOdds.get().getViewdata().getOpeningLine();
                    homeMoneyLineOdds = convertAmericanOdds(currentLines.get("HomeOdds"));
                    awayMoneyLineOdds = convertAmericanOdds(currentLines.get("AwayOdds"));
                }

                MatchWithoutOdds matchWithoutOdds = new MatchWithoutOdds(new DateTime(startDate), awayTeam, homeTeam);
                if(matchSpread != null && totalPoints != null && awayMoneyLineOdds != null) {
                    bookmakerOddsMap.put(bookmaker + " - OpeningLines", new MatchWithOdds(matchWithoutOdds,
                            new Market(matchSpread, awayOdds, homeOdds),
                            new Market(totalPoints, overOdds, underOdds)
                    ));
                }
            }
            list.add(bookmakerOddsMap);
        }

        return list;
    }

    private String getSpreadPrefix() {
        return "";
    }

    private String getMoneyLinePrefix() {
        return "money-line/";
    }

    protected Market getMarket(Element prices, String child1, int length) {
        try {
            String amOddsAwayOrOver = child1.substring(length - 4);
            String child2 = prices.child(1).text();
            String lineString = child2.substring(0, length - 5);
            length = child2.length();
            String amOddsHomeOrUnder = child2.substring(length - 4);
            double decOdds1 = convertAmericanOdds(amOddsAwayOrOver);
            double decOdds2 = convertAmericanOdds(amOddsHomeOrUnder);
            double line = parseLineString(lineString);
            return new Market(line, decOdds1, decOdds2);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    protected Market getMoneyLineMarket(Element prices, String child1) {
        try {
            String child2 = prices.child(1).text();
            double decOdds1 = convertAmericanOdds(child1);
            double decOdds2 = convertAmericanOdds(child2);
            double line = 0;
            return new Market(line, decOdds1, decOdds2);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    protected DateTime getDateTimeUtc(Element matchElement) {
        String attr = matchElement.getElementsByTag("script").get(0).childNode(0).attr("data");
        JSONObject jsonObject = new JSONObject(attr);
        return DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ssZ").parseDateTime(jsonObject.get("startDate").toString());
    }

    protected double parseLineString(String lineString) {
        if (lineString.substring(lineString.length() - 1).equals("½")) {
            String removedHalf = lineString.substring(0, lineString.length() - 1);
            if (removedHalf.substring(0, 1).equals("+")) {
                removedHalf = removedHalf.substring(1);
            }
            if (removedHalf.equals("-")) {
                return -0.5;
            } else if (removedHalf.equals("")) {
                return 0.5;
            }
            double v = Double.parseDouble(removedHalf);
            return (v < 0 ? v - 0.5 : v + 0.5);
        } else {
            if (lineString.substring(0, 1).equals("+")) {
                lineString = lineString.substring(1);
            } else if (lineString.equals("P")) {
                return 0;
            }
            return Double.parseDouble(lineString);
        }
    }

    protected double convertAmericanOdds(String amOddsAwayOrOver) {
        double i = Double.parseDouble(amOddsAwayOrOver);
        return i < 0 ? 1 - 100 / i : 1 + i / 100;
    }

    protected double convertAmericanOdds(Double amOddsAwayOrOver) {
        double i = amOddsAwayOrOver;
        return i < 0 ? 1 - 100 / i : 1 + i / 100;
    }

    protected MatchWithoutOdds getMatchWithoutOdds(Element matchElement) {
        DateTime dateTimeUtc = getDateTimeUtc(matchElement);

        Elements teamElements = matchElement.getElementsByClass("team-name");
        String awayTeamName = teamElements.get(0).text();
        String homeTeamName = teamElements.get(1).text();
        return new MatchWithoutOdds(dateTimeUtc, awayTeamName, homeTeamName);
    }
}
