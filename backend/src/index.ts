import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'PointPath API is running' });
});

// Test endpoint
app.get('/api/search', (req, res) => {
  res.json({ 
    message: 'Search endpoint - coming soon',
    params: req.query 
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});