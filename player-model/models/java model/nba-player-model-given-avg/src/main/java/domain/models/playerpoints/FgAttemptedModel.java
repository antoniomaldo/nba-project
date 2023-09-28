package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class FgAttemptedModel extends H2OModel {

    public FgAttemptedModel() {
        super("FgAttemptedModel.zip");
    }


    public double getFgAttempted(double teamExpPoints,
                                                              double oppExpPoints,
                                                              double minExpected,
                                                              Double averageMinutesInSeason,
                                                              Double lastYearFgAttemptedPerGame,
                                                              Double cumFgAttemptedPerGame,
                                                              double teamFgExp,
                                 double teamPmin) throws PredictException {

        Double cumFgAttemptedPerGameAndMinute = null;

        if (cumFgAttemptedPerGame != null && averageMinutesInSeason != null && averageMinutesInSeason > 0) {
            cumFgAttemptedPerGameAndMinute = cumFgAttemptedPerGame / averageMinutesInSeason;
        }

        double fgExpPerMin = teamFgExp / teamPmin;

        return getFgAttemptedRInputs(minExpected,
                teamExpPoints,
                cumFgAttemptedPerGame,
                cumFgAttemptedPerGameAndMinute,
                oppExpPoints,
                lastYearFgAttemptedPerGame,
                fgExpPerMin);

    }

    public double getFgAttemptedRInputs(
                                 double pmin,
                                 double ownExpPoints,
                                 Double cumFgAttemptedPerGame,
                                 Double cumFgAttemptedPerGameAndMinute,
                                 double oppExpPoints,
                                 Double lastYearFgAttemptedPerGame,
                                 double fgExpPerMin) throws PredictException {

        RowData rowData = new RowData();

        rowData.put("pmin", pmin);
        rowData.put("ownExpPoints", ownExpPoints);

        if(cumFgAttemptedPerGame != null) {
            rowData.put("cumFgAttemptedPerGame", cumFgAttemptedPerGame);
        }

        if(cumFgAttemptedPerGameAndMinute != null){
            rowData.put("cumFgAttemptedPerGameAndMinute", cumFgAttemptedPerGameAndMinute);
        }

        rowData.put("oppExpPoints", oppExpPoints);

        if(lastYearFgAttemptedPerGame != null) {
            rowData.put("lastYearFgAttemptedPerGame", lastYearFgAttemptedPerGame);
        }

        rowData.put("fgExpPerMin", fgExpPerMin);

        return getRegressionPrediction(rowData);
    }
}
