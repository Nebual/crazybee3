const express = require('express')
const cors = require('cors')
const app = express()
const port = 4091
const moment = require('moment-timezone');
const fs = require('fs/promises');

app.use(express.json());
app.use(cors());

const scoreboards = {};
  fs.readdir("./scoreboards/").then((files) => {
    files.forEach(async file => {
      const boardId = (file.match(/(.*)\.json$/) || [])[1];
      try {
        scoreboards[boardId] = JSON.parse(await fs.readFile(`./scoreboards/${file}`));
      } catch (err) {
        console.log(`Failed reading ./scoreboards/${file}: `, err);
        scoreboards[boardId] = []
      }
    });
  }).catch((err) => {
    console.log("Failed to read scoreboards: ", err);
    fs.mkdir("./scoreboards");
  });


function formatScores(scores) {
  return scores.map((scoreObj) => ({
    ...scoreObj,
    datePST: moment(scoreObj.date).tz('America/Vancouver').format('MMM Do YYYY HH:mm')
  }));
}

app.get(['/', '/scoreboards'], async (req, res) => {
  res.json({
    scoreboards: Object.keys(scoreboards).reduce((carry, boardId) => {
      carry[boardId] = formatScores(scoreboards[boardId]);
      return carry;
    }, {}),
  });
})

app.get('/scoreboards/:boardId', async (req, res) => {
  const {boardId} = req.params;
  res.json({scores: formatScores(scoreboards[boardId] || [])});
})
app.put(['/scoreboards/:boardId', '/scoreboards/:boardId/addScore'], async (req, res) => {
  const {boardId} = req.params;
  const newScore = req.body;
  console.log("Received new submitted score: ", boardId, newScore);
  if (!newScore || newScore.score === undefined) {
    return res.status(400).json({"error": "Missing score!"});
  }
  newScore.date = (new Date()).toISOString();
  if (!scoreboards[boardId]) {
    scoreboards[boardId] = [];
  }
  if (!scoreboards[boardId].find(({score, name}) => score == newScore.score && name == newScore.name)) {
    scoreboards[boardId].push(newScore);
    scoreboards[boardId].sort((a,b) => b.score - a.score);
    fs.writeFile(`./scoreboards/${boardId}.json`, JSON.stringify(scoreboards[boardId]));
  } else {
    console.log("Skipping score, its a dupe");
  }
  res.json({scores: formatScores(scoreboards[boardId])});
})

app.listen(port, () => {
  console.log(`Scoreboard app listening at http://localhost:${port}`)
})
