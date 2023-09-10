package sbr.domain;

public enum Bookmaker {

    PINNACLE("238"),
    BET_365("43"),
    MATCHBOOK("626"),
    ;

    private final String id;

    Bookmaker(String id) {
        this.id = id;
    }

    public String getId() {
        return this.id;
    }
}
