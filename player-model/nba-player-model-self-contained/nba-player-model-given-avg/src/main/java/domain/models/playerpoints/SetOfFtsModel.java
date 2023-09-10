package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class SetOfFtsModel extends H2OModel {

    public SetOfFtsModel() {
        super("setOfFt.zip");
    }

    public double getSetOfFtsPred(Double cumFtMadePerFgAttempted,
                                  Double lastYearSetOfFtsPerFg,
                                  Double cumSetOfFtsPerFgAttempted,
                                  double fgAttempted,
                                  Double pmin,
                                  Double ownExpPoints,
                                  Double ftExp,
                                  Double teamFtExp) throws PredictException {
        RowData rowData = new RowData();

        rowData.put("Fg.Attempted", fgAttempted);
        rowData.put("ownExpPoints", ownExpPoints);
        rowData.put("teamFtExp", teamFtExp);

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

        if (ftExp != null) {
            rowData.put("ftExp", ftExp);
        }


        double pred = getRegressionPrediction(rowData);


        return pred;
    }
}
