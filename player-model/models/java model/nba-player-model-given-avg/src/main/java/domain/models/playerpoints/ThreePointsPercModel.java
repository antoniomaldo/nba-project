package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class ThreePointsPercModel extends H2OModel {

    public ThreePointsPercModel() {
        super("threePointsPerc.zip");
    }

    public double getThreePointsPercentage(Double teamExpPoints,double oppExpPoints, double threeFgAttempted,
                                           double fgAttempted, Double lastYearThreePerc,
                                           Double averageMinutesInSeason, Double cumThreePercInSeason,
                                           Double cumPercAttemptedPerMinuteInSeason) throws PredictException {
        RowData rowData = new RowData();

        if (teamExpPoints != null) {
            rowData.put("ownExpPoints", teamExpPoints);
        }

        rowData.put("oppExpPoints", oppExpPoints);
        rowData.put("ownExpDiff", teamExpPoints - oppExpPoints);

        rowData.put("Three.Attempted", threeFgAttempted);
        rowData.put("Fg.Attempted", fgAttempted);

        if (lastYearThreePerc != null) {
            rowData.put("lastYearThreePerc", lastYearThreePerc);
        }
        if (averageMinutesInSeason != null) {
            rowData.put("averageMinutes", averageMinutesInSeason);
        }

        if (cumThreePercInSeason != null) {
            rowData.put("cumThreePerc", cumThreePercInSeason);
        }

        if (cumPercAttemptedPerMinuteInSeason != null) {
            rowData.put("cumPercAttemptedPerMinute", cumPercAttemptedPerMinuteInSeason);
        }

        return getRegressionPrediction(rowData);
    }
}
