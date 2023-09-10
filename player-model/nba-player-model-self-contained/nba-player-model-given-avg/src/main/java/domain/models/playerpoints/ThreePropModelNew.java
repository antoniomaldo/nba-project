package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class ThreePropModelNew extends H2OModel {

    public ThreePropModelNew() {
        super("ThreePropModelNew.zip");
    }

    public double getThreePropOfShots(Double lastYearThreeProp, Double cumThreeProp, double fgAttempted, Double cumTwoPerc, Double cumThreePerc, double ownExpPoints, double fgPred) throws PredictException {
        RowData rowData = new RowData();

        double fgDiff = fgAttempted - fgPred;
        if (lastYearThreeProp != null) {
            rowData.put("lastYearThreeProp", lastYearThreeProp);
        }
        if (cumThreeProp == null) {
            cumThreeProp = lastYearThreeProp;
        }
        if (cumThreeProp != null) {
            rowData.put("cumThreeProp", cumThreeProp);
        }


        rowData.put("Fg.Attempted", fgAttempted);
        rowData.put("ownExpPoints", ownExpPoints);
        rowData.put("fgDiff", fgDiff);

        if (cumTwoPerc != null) {
            rowData.put("cumTwoPerc", cumTwoPerc);
        }
        if (cumThreePerc != null) {
            rowData.put("cumThreePerc", cumThreePerc);
        }

        return getRegressionPrediction(rowData);
    }
}
