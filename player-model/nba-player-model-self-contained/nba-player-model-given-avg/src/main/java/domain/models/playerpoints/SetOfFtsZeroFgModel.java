package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class SetOfFtsZeroFgModel extends H2OModel {

    public SetOfFtsZeroFgModel() {
        super("setOfFtZeroFg.zip");
    }

    public double getSetOfFtsPred(Double cumFtMadePerFgAttempted,
                                  Double lastYearSetOfFtsPerFg,
                                  Double cumSetOfFtsPerFgAttempted,
                                  Double pmin,
                                  Double ownExpPoints) throws PredictException {
        RowData rowData = new RowData();

        if (cumFtMadePerFgAttempted != null) {
            rowData.put("cumFtMadePerFgAttempted", cumFtMadePerFgAttempted);
        }
        if (lastYearSetOfFtsPerFg != null) {
            rowData.put("lastYearSetOfFtsPerFg", lastYearSetOfFtsPerFg);
        }
        if (cumSetOfFtsPerFgAttempted != null) {
            rowData.put("cumSetOfFtsPerFgAttempted", cumSetOfFtsPerFgAttempted);
        }
        if (pmin != null) {
            rowData.put("pmin", pmin);
        }

        rowData.put("ownExpPoints", ownExpPoints);


        return getRegressionPrediction(rowData);
    }
}
