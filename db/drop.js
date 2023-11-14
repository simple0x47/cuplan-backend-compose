db = db.getSiblingDB("cuplan");

if (db) {
    db.dropDatabase();
}