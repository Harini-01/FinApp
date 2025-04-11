const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Manually connect to the Firestore Emulator
if (process.env.NODE_ENV === "development") {
  admin.firestore().settings({
    host: "localhost:8081", // Firestore Emulator
    ssl: false, // Disable SSL since emulators don't use it
  });
}

// Create a Cloud Function to add a user to Firestore
exports.addUser = functions.https.onRequest(async (req, res) => {
  const { name, email } = req.body;
  const userRef = admin.firestore().collection("users").doc();

  try {
    await userRef.set({ name, email });
    res.status(200).send({ message: "User added successfully!" });
  } catch (error) {
    res.status(500).send({ error: "Error adding user" });
  }
});