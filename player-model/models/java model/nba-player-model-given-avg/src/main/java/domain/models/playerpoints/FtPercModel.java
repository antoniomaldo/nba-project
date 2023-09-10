package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class FtPercModel extends H2OModel {

    public FtPercModel() {
        super("ftPercModel.zip");
    }

    public double getFtPerc(Double cumFtMadePerFgAttempted,
                                  Double lastYearSetOfFtsPerFg,
                                  Double cumSetOfFtsPerFgAttempted,
                                  double fgAttempted,
                                  Double pmin,
                                  Double lastYearFtPerc,
                                  Double cumFtPerc,
                                  double setOfFts
                                  ) throws PredictException {
        RowData rowData = new RowData();

        rowData.put("Fg.Attempted", fgAttempted);

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

        if(cumFtPerc != null){
            rowData.put("cumFtPerc", cumFtPerc);
        }

        if(lastYearFtPerc != null){
            rowData.put("lastYearFtPerc", lastYearFtPerc);
        }
        rowData.put("setOfFts", setOfFts);

        double pred = getClassificationPrediction(rowData);


        return pred;
    }
}
