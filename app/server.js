const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// لازم تحطه في Environment Variable
const MONGODB_URI = process.env.MONGODB_URI;

// Database + Collection names
const DB_NAME = process.env.DB_NAME || "nti-db";
const COLLECTION_NAME = process.env.COLLECTION_NAME || "messages";

let client;
let db;

async function connectDB() {
  if (!MONGODB_URI) {
    console.error("❌ MONGODB_URI is not set in environment variables");
    return;
  }

  try {
    client = new MongoClient(MONGODB_URI);
    await client.connect();
    db = client.db(DB_NAME);

    console.log("✅ Connected to MongoDB Atlas successfully");
  } catch (err) {
    console.error("❌ MongoDB connection error:", err.message);
  }
}

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    message: "Version 3 Running 🚀🚀 (Mongo Enabled)",
    status: "ok",
  });
});

// Health endpoint (لـ Kubernetes readiness/liveness)
app.get("/health", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).send("DB Not Connected");
    }

    await db.command({ ping: 1 });
    return res.status(200).send("OK");
  } catch (err) {
    return res.status(500).send("DB Ping Failed");
  }
});

// Test DB endpoint 
app.get("/db-test", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: "DB Not Connected" });
    }

    const collection = db.collection(COLLECTION_NAME);

    const data = {
      message: "Hello from EKS 🚀",
      createdAt: new Date(),
    };

    const result = await collection.insertOne(data);

    res.json({
      status: "ok",
      insertedId: result.insertedId,
      data,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      error: err.message,
    });
  }
});

// Get all records
app.get("/messages", async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: "DB Not Connected" });
    }

    const collection = db.collection(COLLECTION_NAME);
    const messages = await collection.find({}).sort({ createdAt: -1 }).toArray();

    res.json({
      status: "ok",
      count: messages.length,
      messages,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      error: err.message,
    });
  }
});

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  await connectDB();
});
