package domain.models.playerpoints;

import domain.models.H2OModel;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class FgAttemptedModelRotoWire extends H2OModel {

    public FgAttemptedModelRotoWire() {
        super("FgAttemptedModelRotoWire.zip");
    }


    public double getFgAttempted(double teamExpPoints,
                                 double oppExpPoints,
                                 double minExpected,
                                 Double averageMinutesInSeason,
                                 Double lastYearFgAttemptedPerGame,
                                 Double cumFgAttemptedPerGame) throws PredictException {

        Double cumFgAttemptedPerGameAndMinute = null;

        if (cumFgAttemptedPerGame != null && averageMinutesInSeason != null && averageMinutesInSeason > 0) {
            cumFgAttemptedPerGameAndMinute = cumFgAttemptedPerGame / averageMinutesInSeason;
        }

        Double cumFgAttemptedPerGameAndMinuteGivenPmin = null;
        if(cumFgAttemptedPerGameAndMinute != null){
            cumFgAttemptedPerGameAndMinuteGivenPmin = cumFgAttemptedPerGameAndMinute * minExpected;
        }


        return getFgAttemptedRInputs(minExpected,
                teamExpPoints,
                cumFgAttemptedPerGame,
                cumFgAttemptedPerGameAndMinute,
                oppExpPoints,
                lastYearFgAttemptedPerGame,
                cumFgAttemptedPerGameAndMinuteGivenPmin);

    }

    public double getFgAttemptedRInputs(
            double pmin,
            double ownExpPoints,
            Double cumFgAttemptedPerGame,
            Double cumFgAttemptedPerGameAndMinute,
            double oppExpPoints,
            Double lastYearFgAttemptedPerGame,
            Double cumFgAttemptedPerGameAndMinuteGivenPmin) {

        RowData rowData = new RowData();

        rowData.put("pmin", pmin);
        rowData.put("ownExpPoints", ownExpPoints);

        if (cumFgAttemptedPerGame != null) {
            rowData.put("cumFgAttemptedPerGame", cumFgAttemptedPerGame);
        }

        if (cumFgAttemptedPerGameAndMinute != null) {
            rowData.put("cumFgAttemptedPerGameAndMinute", cumFgAttemptedPerGameAndMinute);
        }

        rowData.put("oppExpPoints", oppExpPoints);

        if (lastYearFgAttemptedPerGame != null) {
            rowData.put("lastYearFgAttemptedPerGame", lastYearFgAttemptedPerGame);
        }
        if(cumFgAttemptedPerGameAndMinuteGivenPmin!=null){
            rowData.put("cumFgAttemptedPerGameAndMinuteGivenPmin", cumFgAttemptedPerGameAndMinuteGivenPmin);
        }

        try {
            return getRegressionPrediction(rowData);
        } catch (PredictException e) {
            e.printStackTrace();
            return -1;
        }
    }
}
