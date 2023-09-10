package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class TwoPointsPercModel extends H2OModel {

    public TwoPointsPercModel() {
        super("twoPointsPerc.zip");
    }

    public double getTwoPointsPercentage(double teamExpPoints,
                                         double oppExpPoints,
                                         Double lastYeartwoPerc, Double averageMinutesInSeason, Double cumTwoPercInSeason,
                                         Double cumPercAttemptedPerMinuteInSeason,
                                         double twoPointsAttempted, double fgAttempted
                                         ) throws PredictException {
        RowData rowData = new RowData();

        if (lastYeartwoPerc != null) {
            rowData.put("lastYeartwoPerc", lastYeartwoPerc);
        }
        if (averageMinutesInSeason != null) {
            rowData.put("averageMinutes", averageMinutesInSeason);
        }
        if (cumTwoPercInSeason != null) {
            rowData.put("cumTwoPerc", cumTwoPercInSeason);
        }
        rowData.put("twoPointsAttempted", twoPointsAttempted);
        rowData.put("Fg.Attempted", fgAttempted);
        if (cumPercAttemptedPerMinuteInSeason != null) {
            rowData.put("cumPercAttemptedPerMinute", cumPercAttemptedPerMinuteInSeason);
        }

        rowData.put("ownExpPoints", teamExpPoints);
        rowData.put("oppExpPoints", oppExpPoints);
        rowData.put("ownExpDiff", teamExpPoints - oppExpPoints);

        return getRegressionPrediction(rowData);
    }
}
