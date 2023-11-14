db = db.getSiblingDB("cuplan");

db.invitation_code.createIndex({ "Code": 1 }, { unique: true });