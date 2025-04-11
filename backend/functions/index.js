const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require('firebase-admin/firestore');

admin.initializeApp();

// Manually connect to the Firestore Emulator
if (process.env.NODE_ENV === "development") {
  admin.firestore().settings({
    host: "localhost:8081", // Firestore Emulator
    ssl: false, // Disable SSL since emulators don't use it
  });
}

// Create a new user document with initial structure
exports.addUser = functions.https.onRequest(async (req, res) => {
  const { name, email, trackingMethod = 'manual' } = req.body;

  // Input validation
  if (!name || !email) {
    return res.status(400).send({ 
      error: "Missing required fields",
      required: ["name", "email"]
    });
  }

  const userRef = admin.firestore().collection("users").doc();

  try {
    await userRef.set({ 
      name, 
      email,
      settings: {
        trackingMethod, // 'manual' or 'sms'
        notificationsEnabled: true
      },
      createdAt: FieldValue.serverTimestamp()
    });

    console.log(`User created successfully with ID: ${userRef.id}`);
    
    res.status(200).send({ 
      message: "User added successfully!",
      userId: userRef.id 
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).send({ 
      error: "Error adding user",
      details: error.message 
    });
  }
});

// Add expense as subcollection to user
exports.addExpense = functions.https.onRequest(async (req, res) => {
  const { userId, amount, category, description, date } = req.body;
  
  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const expenseRef = userRef.collection('expenses').doc();

    await expenseRef.set({
      amount,
      category,
      description,
      date,
      createdAt: FieldValue.serverTimestamp()
    });

    // Update monthly spending totals in user document
    const month = new Date(date).toISOString().slice(0, 7); // Format: YYYY-MM
    const monthlyStatsRef = userRef.collection('monthlyStats').doc(month);
    
    await admin.firestore().runTransaction(async (transaction) => {
      const monthlyDoc = await transaction.get(monthlyStatsRef);
      
      if (!monthlyDoc.exists) {
        transaction.set(monthlyStatsRef, {
          totalSpent: amount,
          categories: {
            [category]: amount
          }
        });
      } else {
        const currentData = monthlyDoc.data();
        transaction.update(monthlyStatsRef, {
          totalSpent: currentData.totalSpent + amount,
          [`categories.${category}`]: (currentData.categories[category] || 0) + amount
        });
      }
    });

    res.status(200).send({ message: "Expense added successfully!" });
  } catch (error) {
    res.status(500).send({ error: "Error adding expense" });
  }
});

// Add financial goal as subcollection to user
exports.addGoal = functions.https.onRequest(async (req, res) => {
  const { userId, targetAmount, title, deadline } = req.body;
  
  try {
    const goalRef = admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('goals')
      .doc();

    await goalRef.set({
      targetAmount,
      title,
      deadline,
      currentAmount: 0,
      status: 'active',
      createdAt: FieldValue.serverTimestamp(),
      progress: 0,
      lastUpdated: FieldValue.serverTimestamp()
    });

    res.status(200).send({ message: "Goal added successfully!" });
  } catch (error) {
    res.status(500).send({ error: "Error adding goal" });
  }
});

// Add new function to update tracking method
exports.updateTrackingMethod = functions.https.onRequest(async (req, res) => {
  const { userId, trackingMethod } = req.body;

  // Validate tracking method
  if (!['manual', 'sms'].includes(trackingMethod)) {
    return res.status(400).send({ error: "Invalid tracking method" });
  }

  try {
    const userRef = admin.firestore().collection("users").doc(userId);
    
    await userRef.update({
      'settings.trackingMethod': trackingMethod,
      'settings.lastUpdated': admin.firestore.FieldValue.serverTimestamp()
    });

    res.status(200).send({ 
      message: "Tracking method updated successfully",
      trackingMethod 
    });
  } catch (error) {
    res.status(500).send({ error: "Error updating tracking method" });
  }
});