const admin = require("firebase-admin");
const dotenv = require("dotenv");
dotenv.config();

// Initialize Firebase Admin SDK
const serviceAccount = require(process.env.FIREBASE_PRIVATE_KEY_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://finapp-d7e39.firebaseio.com",  // Ensure this is the correct database URL
});

// Manually configure Firestore Emulator for Admin SDK
const firestore = admin.firestore();
firestore.settings({
  host: "localhost:8080", // Firestore Emulator host and port
  ssl: false, // Disable SSL as emulators don't use SSL
});

// Test Firestore connection by adding some data
const testRef = firestore.collection("testCollection").doc("testDoc");

testRef.set({
  name: "Test User",
  email: "test@example.com",
})
.then(() => {
  console.log("Document successfully written to Firestore Emulator!");
})
.catch((error) => {
  console.error("Error writing document:", error);
});
