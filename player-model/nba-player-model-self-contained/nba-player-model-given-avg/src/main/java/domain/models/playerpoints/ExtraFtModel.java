package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class ExtraFtModel extends H2OModel {

    public ExtraFtModel() {
        super("extraFtModel.zip");
    }

    public double getExtraFtProb(double setOfFts,
                                 Double lastYearExtraProb,
                                 Double cumExtraProb,
                                 double fgAttempted,
                                 Double pmin) throws PredictException {
        RowData rowData = new RowData();

        rowData.put("Fg.Attempted", fgAttempted);
        rowData.put("setOfFts", setOfFts);

        if (lastYearExtraProb != null) {
            rowData.put("lastYearExtraProb", lastYearExtraProb);
        }
        if (cumExtraProb != null) {
            rowData.put("cumExtraProb", cumExtraProb);
        }
        if (pmin != null) {
            rowData.put("pmin", pmin);
        }

        return getClassificationPrediction(rowData);
    }
}
