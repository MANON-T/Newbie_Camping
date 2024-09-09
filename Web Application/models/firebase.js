const admin = require("firebase-admin");

const serviceAccount = require("../serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "Your_StorageBucket_Link"
});

const db = admin.firestore();
const Firestorage = admin.storage().bucket();

module.exports = { db, Firestorage };