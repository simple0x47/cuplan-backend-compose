db = db.getSiblingDB("cuplan");

db.member.createIndex({ "UserId": 1, "OrgId": 1 }, { unique: true });