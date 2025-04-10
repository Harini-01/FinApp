const admin = require("firebase-admin");
const dotenv = require("dotenv");
dotenv.config();

// Initialize Firebase Admin SDK
const serviceAccount = require(process.env.FIREBASE_PRIVATE_KEY_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://finapp-d7e39.firebaseio.com",  // Firebase Realtime Database URL (if you use it)
});

// Point Firestore to the local emulator for local development
if (process.env.NODE_ENV === "development") {
  admin.firestore().settings({
    host: "localhost:8080",  // This is the Firestore emulator's default port
    ssl: false,              // Disable SSL for local emulator connection
  });
}

module.exports = admin;
