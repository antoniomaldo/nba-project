package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class ThreePropModel extends H2OModel {

    public ThreePropModel() {
        super("threePropModel.zip");
    }

    public double getThreePropOfShots(Double lastYearThreeProp, Double cumThreeProp, double fgAttempted, Double cumTwoPerc, Double cumThreePerc, double ownExpPoints) throws PredictException {
        RowData rowData = new RowData();

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

        if (cumTwoPerc != null) {
            rowData.put("cumTwoPerc", cumTwoPerc);
        }
        if (cumThreePerc != null) {
            rowData.put("cumThreePerc", cumThreePerc);
        }

        return getRegressionPrediction(rowData);
    }
}
