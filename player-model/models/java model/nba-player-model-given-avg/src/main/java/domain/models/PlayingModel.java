package domain.models;

import java.util.HashMap;
import java.util.Map;

public class PlayingModel {

    private static Map<Integer, Double> PREDICTIONS = new HashMap<Integer, Double>(){{
        put(1,0.5339959);
        put(2,0.5576789);
        put(3,0.5862707);
        put(4,0.6189859);
        put(5,0.6548349);
        put(6,0.6926414);
        put(7,0.731106);
        put(8,0.7689117);
        put(9,0.8048501);
        put(10,0.8379373);
        put(11,0.8674936);
        put(12,0.8931686);
        put(13,0.9149153);
        put(14,0.9329269);
        put(15,0.9475583);
        put(16,0.95925);
        put(17,0.9684663);
        put(18,0.975652);
        put(19,0.9812065);
        put(20,0.9854728);
        put(21,0.9887349);
        put(22,0.9912221);
        put(23,0.993116);
        put(24,0.9945579);
        put(25,0.9956567);
        put(26,0.9964951);
        put(27,0.9971362);
        put(28,0.997627);
        put(29,0.9980032);
        put(30,0.9982912);
        put(31,0.9985106);
        put(32,0.998676);
        put(33,0.9987979);
        put(34,0.9988836);
        put(35,0.998938);
        put(36,0.9989638);
        put(37,0.9989615);
        put(38,0.9989293);
        put(39,0.9988629);
        put(40,0.9987544);
    }};

    private static Map<Integer, Double> PREDICTIONS_ROTO = new HashMap<Integer, Double>(){{
        put(1, 0.442257);
        put(2, 0.4915308);
        put(3, 0.5416645);
        put(4, 0.5916327);
        put(5, 0.6403974);
        put(6, 0.6869945);
        put(7, 0.7306093);
        put(8, 0.7706298);
        put(9, 0.8066703);
        put(10, 0.8385673);
        put(11, 0.8663524);
        put(12, 0.8902116);
        put(13, 0.9104393);
        put(14, 0.9273956);
        put(15, 0.9414691);
        put(16, 0.9530486);
        put(17, 0.9625039);
        put(18, 0.9701737);
        put(19, 0.9763591);
        put(20, 0.9813219);
        put(21, 0.9852859);
        put(22, 0.9884395);
        put(23, 0.9909394);
        put(24, 0.9929147);
        put(25, 0.994471);
        put(26, 0.995694);
        put(27, 0.9966526);
        put(28, 0.9974023);
        put(29, 0.9979874);
        put(30, 0.9984431);
        put(31, 0.9987974);
        put(32, 0.9990724);
        put(33, 0.9992854);
        put(34, 0.9994502);
        put(35, 0.9995775);
        put(36, 0.9996757);
        put(37, 0.9997514);
        put(38, 0.9998096);
        put(39, 0.9998543);
    }};

    public static double probabilityOfPlaying(double minExpected){
        int minExpectedInt = (int) minExpected;
        if(minExpected > 40){
            return 1d;
        }else if(minExpected < 1){
            return 0d;
        }else{
            return PREDICTIONS.get(minExpectedInt);
        }
    }
    public static double probabilityOfPlayingForRoto(double minExpected){
        int minExpectedInt = (int) minExpected;
        if(minExpected > 39){
            return 1d;
        }else if(minExpected < 1){
            return 0d;
        }else{
            return PREDICTIONS_ROTO.get(minExpectedInt);
        }
    }

    public static double meanMissingPlayers(int totalPlayersWithPreds){
        if(totalPlayersWithPreds <= 8){
            return 0.01;
        }else if(totalPlayersWithPreds == 9){
            return 0.17;
        }else if(totalPlayersWithPreds == 10){
            return 0.35;
        }else if(totalPlayersWithPreds == 11){
            return 0.7;
        }else if(totalPlayersWithPreds == 12){
            return 1.3;
        }else{
            return 2;
        }
    }


}
