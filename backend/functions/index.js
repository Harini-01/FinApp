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

    // Create user document with initial structure
    await userRef.set({ 
      name, 
      email,
      password: hashedPassword,
      settings: {
        trackingMethod,
        notificationsEnabled: true
      },
      createdAt: FieldValue.serverTimestamp()
    });

    // Initialize empty goals collection
    const goalsRef = userRef.collection('goals');
    await goalsRef.doc('.info').set({
      createdAt: FieldValue.serverTimestamp()
    });

    console.log(`User and goals collection created successfully with ID: ${userRef.id}`);
    
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

// Update the addExpense function to include icon and category data
exports.addExpense = functions.https.onRequest(async (req, res) => {
  const { userId, category, amount, iconData, color } = req.body;

  if (!userId || !category || amount === undefined) {
    return res.status(400).send({ 
      error: "Missing required fields",
      required: ["userId", "category", "amount"]
    });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const expenseRef = userRef.collection('expenses').doc();

    const now = admin.firestore.Timestamp.now();

    await expenseRef.set({
      amount: Number(amount),
      category,
      iconData: Number(iconData) || 0,
      color: Number(color) || 0,
      date: now,
      createdAt: now
    });

    // Add monthly stats update
    const month = now.toDate().toISOString().slice(0, 7); // YYYY-MM
    const monthlyStatsRef = userRef.collection('monthlyStats').doc(month);

    await monthlyStatsRef.set({
      totalExpenses: admin.firestore.FieldValue.increment(Number(amount)),
      lastUpdated: now
    }, { merge: true });

    console.log('Expense added successfully:', {
      expenseId: expenseRef.id,
      amount,
      category
    });

    res.status(200).send({ 
      success: true,
      expenseId: expenseRef.id
    });

  } catch (error) {
    console.error('Error adding expense:', error);
    res.status(500).send({ 
      error: "Failed to add expense",
      details: error.message
    });
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
  const { userId, ...updateData } = req.body;

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

    if (!userDoc.exists) {
      return res.status(404).send({ 
        error: "User not found",
        providedUserId: userId
      });
    }

    // Get existing profile data
    const existingProfile = userDoc.data().profile || {};

    // Merge new data with existing profile data
    const updatedProfile = {
      ...existingProfile,
      ...updateData,
      lastUpdated: FieldValue.serverTimestamp()
    };

    // Update only the profile field
    await userRef.update({
      profile: updatedProfile
    });

    console.log('Profile updated successfully');

    res.status(200).send({
      message: "Profile updated successfully",
      profile: updatedProfile
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).send({
      error: "Failed to update profile",
      details: error.message
    });
  }
});

// Add new function to get user data
exports.getUserData = functions.https.onRequest(async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).send({ error: "Missing user ID" });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).send({ error: "User not found" });
    }

    // Get the entire user document
    const userData = userDoc.data();

    res.status(200).send(userData);
  } catch (error) {
    console.error('Error fetching user data:', error);
    res.status(500).send({
      error: "Failed to fetch user data",
      details: error.message
    });
  }
});

exports.getGoals = functions.https.onRequest(async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).send({ 
      error: "Missing user ID" 
    });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).send({ error: "User not found" });
    }

    // Get goals subcollection
    const goalsRef = userRef.collection('goals');
    const goalsSnapshot = await goalsRef.get();

    const goals = [];
    goalsSnapshot.forEach(doc => {
      goals.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // Add debug log
    console.log(`Retrieved ${goals.length} goals for user ${userId}`);

    res.status(200).send(goals);

  } catch (error) {
    console.error('Error fetching goals:', error);
    res.status(500).send({
      error: "Failed to fetch goals",
      details: error.message
    });
  }
});

exports.getProfile = functions.https.onRequest(async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).send({ error: "Missing user ID" });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).send({ error: "User not found" });
    }

    const userData = userDoc.data();
    res.status(200).send({
      profile: userData.profile || {},
      settings: userData.settings || {}
    });

  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).send({
      error: "Failed to fetch profile",
      details: error.message
    });
  }
});

exports.updateGoalAmount = functions.https.onRequest(async (req, res) => {
  const { userId, goalId, amount } = req.body;

  if (!userId || !goalId || amount === undefined) {
    return res.status(400).send({ 
      error: "Missing required fields" 
    });
  }

  try {
    const goalRef = admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('goals')
      .doc(goalId);

    const goalDoc = await goalRef.get();
    if (!goalDoc.exists) {
      return res.status(404).send({ error: "Goal not found" });
    }

    const currentData = goalDoc.data();
    const newAmount = currentData.currentAmount + amount;
    const progress = (newAmount / currentData.targetAmount) * 100;

    await goalRef.update({
      currentAmount: newAmount,
      progress: progress,
      lastUpdated: FieldValue.serverTimestamp()
    });

    res.status(200).send({
      message: "Goal updated successfully",
      currentAmount: newAmount,
      progress: progress
    });

  } catch (error) {
    console.error('Error updating goal:', error);
    res.status(500).send({
      error: "Failed to update goal",
      details: error.message
    });
  }
});

exports.getExpenses = functions.https.onRequest(async (req, res) => {
  const { userId } = req.body;

  if (!userId) {
    return res.status(400).send({ 
      error: "Missing user ID" 
    });
  }

  try {
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).send({ error: "User not found" });
    }

    // Get expenses subcollection
    const expensesRef = userRef.collection('expenses');
    const expensesSnapshot = await expensesRef.orderBy('date', 'desc').get();

    const expenses = [];
    expensesSnapshot.forEach(doc => {
      expenses.push({
        id: doc.id,
        ...doc.data(),
        // Convert Firestore Timestamp to ISO string for date
        date: doc.data().date.toDate().toISOString(),
      });
    });

    // Calculate total expenses
    const totalExpenses = expenses.reduce((sum, expense) => sum + expense.amount, 0);

    console.log(`Retrieved ${expenses.length} expenses for user ${userId}`);
    console.log('Total expenses:', totalExpenses);

    res.status(200).send({
      expenses,
      totalExpenses,
      count: expenses.length
    });

  } catch (error) {
    console.error('Error fetching expenses:', error);
    res.status(500).send({
      error: "Failed to fetch expenses",
      details: error.message
    });
  }
});