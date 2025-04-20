const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config()

const app = express();
app.use(cors({ origin: '*' }));

app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error(err));

app.use('/api/auth', require('./routes/auth'));

const PORT =3000;
app.listen(PORT,'0.0.0.0', () => console.log(`Server running on port ${PORT}`));
