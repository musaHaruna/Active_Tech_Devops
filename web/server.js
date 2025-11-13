const os = require('os');
const express = require('express');
const app = express();
const redis = require('redis');

// Create Redis client (for redis v3)
const redisClient = redis.createClient({
  host: 'redis',
  port: 6379
});

app.get('/', function (req, res) {
  redisClient.get('numVisits', function (err, numVisits) {
    if (err) {
      console.error("Redis error:", err);
      return res.status(500).json({ error: "Redis error" });
    }

    let visits = parseInt(numVisits) + 1;
    if (isNaN(visits)) {
      visits = 1;
    }

    // Update Redis
    redisClient.set('numVisits', visits);

    // Send JSON response
    res.json({
      message: "Automate all the things!",
      hostname: os.hostname(),
      total_visits: visits,
      timestamp: Math.floor(Date.now() / 1000)
    });
  });
});

app.listen(5000, function () {
  console.log('Web application is listening on port 5000');
});
