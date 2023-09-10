package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class ThreePointsPercModelNew extends H2OModel {

    public ThreePointsPercModelNew() {
        super("threePointsPercNew.zip");
    }

    public double getThreePointsPercentage(double teamExpPoints,double oppExpPoints, double threeFgAttempted,
                                           double fgAttempted, Double lastYearThreePerc,
                                           double pmin, Double cumThreePercInSeason,
                                           Double cumPercAttemptedPerMinuteInSeason) throws PredictException {
        RowData rowData = new RowData();

            rowData.put("ownExpPoints", teamExpPoints);

        rowData.put("oppExpPoints", oppExpPoints);
        rowData.put("ownExpDiff", teamExpPoints - oppExpPoints);

        rowData.put("Three.Attempted", threeFgAttempted);
        rowData.put("Fg.Attempted", fgAttempted);

        if (lastYearThreePerc != null) {
            rowData.put("lastYearThreePerc", lastYearThreePerc);
        }
            rowData.put("pmin", pmin);
            rowData.put("lastSeason", "1");

        if (cumThreePercInSeason != null) {
            rowData.put("cumThreePerc", cumThreePercInSeason);
        }

        if (cumPercAttemptedPerMinuteInSeason != null) {
            rowData.put("cumPercAttemptedPerMinute", cumPercAttemptedPerMinuteInSeason);
        }

        return getRegressionPrediction(rowData);
    }
}
