package domain.models;

import java.io.IOException;
import java.io.InputStream;

import hex.genmodel.MojoModel;
import hex.genmodel.MojoReaderBackend;
import hex.genmodel.MojoReaderBackendFactory;
import hex.genmodel.easy.EasyPredictModelWrapper;
import hex.genmodel.easy.RowData;
import hex.genmodel.easy.exception.PredictException;

public class H2OModel {

    private final EasyPredictModelWrapper model;

    public H2OModel(String modelPath) {
        MojoModel mojoModel = null;
        try {
            InputStream resourceAsStream = getClass().getResourceAsStream("/"+ modelPath);
            MojoReaderBackend readerBackend = MojoReaderBackendFactory.createReaderBackend(resourceAsStream, MojoReaderBackendFactory.CachingStrategy.MEMORY);
            mojoModel = MojoModel.load(readerBackend);
           // mojoModel = MojoModel.load("./src/main/resources/" + modelPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
        this.model = new EasyPredictModelWrapper(mojoModel);
    }

    public double getRegressionPrediction(RowData rowData) throws PredictException {
        double treePrediction;
        try {
            treePrediction = this.model.predictRegression(rowData).value;
        } catch (PredictException e) {
            e.printStackTrace();
            throw new PredictException("");
        }
        return treePrediction;
    }

    public double getClassificationPrediction(RowData rowData) throws PredictException {
        double treePrediction;
        try {
            treePrediction = this.model.predictBinomial(rowData).classProbabilities[1];
        } catch (PredictException e) {
            e.printStackTrace();
            throw new PredictException("");
        }
        return treePrediction;
    }
}
