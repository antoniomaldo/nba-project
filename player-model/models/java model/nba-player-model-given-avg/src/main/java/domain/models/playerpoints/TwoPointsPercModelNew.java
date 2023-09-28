package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class TwoPointsPercModelNew extends H2OModel {

    public TwoPointsPercModelNew() {
         super("twoPointsPercNew.zip");
    }

    public double getTwoPointsPercentage(double teamExpPoints,
                                         double oppExpPoints,
                                         Double lastYeartwoPerc, double pmin, Double cumTwoPercInSeason,
                                         Double cumPercAttemptedPerMinuteInSeason,
                                         double twoPointsAttempted, double fgAttempted
                                         ) throws PredictException {
        RowData rowData = new RowData();

        if (lastYeartwoPerc != null) {
            rowData.put("lastYeartwoPerc", lastYeartwoPerc);
        }
//        if (pmin != null) {
            rowData.put("pmin", pmin);
//        }
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
