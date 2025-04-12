const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require('firebase-admin/firestore');
const bcrypt = require('bcrypt');  // Add this import

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
  const { name, email, password, trackingMethod = 'manual' } = req.body;

  // Input validation
  if (!name || !email || !password) {
    return res.status(400).send({ 
      error: "Missing required fields",
      required: ["name", "email", "password"]
    });
  }

  const userRef = admin.firestore().collection("users").doc();

  try {
    // Hash password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    await userRef.set({ 
      name, 
      email,
      password: hashedPassword,  // Store hashed password
      settings: {
        trackingMethod,
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

// Add new login function
exports.login = functions.https.onRequest(async (req, res) => {
  const { email, password } = req.body;

  // Input validation
  if (!email || !password) {
    return res.status(400).send({ 
      error: "Missing required fields",
      required: ["email", "password"]
    });
  }

  try {
    // Find user by email
    const usersRef = admin.firestore().collection('users');
    const snapshot = await usersRef.where('email', '==', email).limit(1).get();

    if (snapshot.empty) {
      return res.status(404).send({ error: "User not found" });
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    // Compare password
    const isPasswordValid = await bcrypt.compare(password, userData.password);

    if (!isPasswordValid) {
      return res.status(401).send({ error: "Invalid password" });
    }

    res.status(200).send({
      message: "Login successful",
      userId: userDoc.id,
      user: {
        name: userData.name,
        email: userData.email,
        settings: userData.settings
      }
    });

  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).send({
      error: "Login failed",
      details: error.message
    });
  }
});

// Add update profile function
exports.updateProfile = functions.https.onRequest(async (req, res) => {
  const { userId, name, age, monthlyIncome, fixedExpense, financialGoal } = req.body;

  // Add debug logs
  console.log('Updating profile for userId:', userId);
  console.log('Request body:', req.body);

  if (!userId) {
    return res.status(400).send({ 
      error: "Missing user ID" 
    });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();

    // Add debug log
    console.log('User document exists:', userDoc.exists);

    if (!userDoc.exists) {
      return res.status(404).send({ 
        error: "User not found",
        providedUserId: userId
      });
    }

    // Update with name instead of username
    await userRef.update({
      profile: {
        name: name || null,
        age: age || null,
        monthlyIncome: monthlyIncome || 0,
        fixedExpense: fixedExpense || 0,
        financialGoal: financialGoal || null,
        lastUpdated: FieldValue.serverTimestamp()
      }
    });

    // Add debug log
    console.log('Profile updated successfully');

    res.status(200).send({
      message: "Profile updated successfully",
      profile: {
        name,
        age,
        monthlyIncome,
        fixedExpense,
        financialGoal
      }
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    console.error('Error details:', {
      code: error.code,
      message: error.message,
      stack: error.stack
    });
    
    res.status(500).send({
      error: "Failed to update profile",
      details: error.message
    });
  }
});