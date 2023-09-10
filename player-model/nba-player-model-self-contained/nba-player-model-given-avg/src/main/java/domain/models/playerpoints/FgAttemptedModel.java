package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class FgAttemptedModel extends H2OModel {

    public FgAttemptedModel() {
        super("FgAttemptedModel.zip");
    }


    public double getFgAttempted(double teamExpPoints,
                                 double oppExpPoints,
                                 double minExpected,
                                 Double averageMinutesInSeason,
                                 Double lastYearFgAttemptedPerGame,
                                 Double cumFgAttemptedPerGame,
                                 double teamFgExp, double teamAvgMinutest) throws PredictException {
        return getFgAttempted(teamExpPoints, oppExpPoints, minExpected, averageMinutesInSeason, lastYearFgAttemptedPerGame, cumFgAttemptedPerGame, teamFgExp, teamAvgMinutest, "2021");
    }

                                 public double getFgAttempted(double teamExpPoints,
                                 double oppExpPoints,
                                 double minExpected,
                                 Double averageMinutesInSeason,
                                 Double lastYearFgAttemptedPerGame,
                                 Double cumFgAttemptedPerGame,
                                 double teamFgExp, double teamAvgMinutest, String seasonYearFactor) throws PredictException {

        RowData rowData = new RowData();

        rowData.put("pmin", minExpected);

        if (averageMinutesInSeason != null) {
            rowData.put("averageMinutes", averageMinutesInSeason);
        }

        if (cumFgAttemptedPerGame != null && averageMinutesInSeason != null && averageMinutesInSeason > 0) {
            rowData.put("cumFgAttemptedPerGameAndMinute", cumFgAttemptedPerGame / averageMinutesInSeason);
        }

        if (lastYearFgAttemptedPerGame != null) {
            rowData.put("lastYearFgAttemptedPerGame", lastYearFgAttemptedPerGame);
        }

        rowData.put("ownExpPoints", teamExpPoints);
        rowData.put("oppExpPoints", oppExpPoints);
        rowData.put("teamFgExp", teamFgExp);
        rowData.put("teamAvgMinutest", teamAvgMinutest);
        rowData.put("seasonYearFactor", seasonYearFactor);

        if (cumFgAttemptedPerGame != null) {
            rowData.put("cumFgAttemptedPerGame", cumFgAttemptedPerGame);
        }

        return getRegressionPrediction(rowData);
    }
}
