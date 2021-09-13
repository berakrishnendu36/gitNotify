var express = require('express');
var cron = require('node-cron');

const { login, logout } = require('./utils/auth');

const { findUsersAndNotify } = require('./utils/scheduler');

var app = express();
var bodyParser = require('body-parser');
app.use(bodyParser.json());

var task = cron.schedule('0 0 * * * *', () => {
    //console.log('Task started!');
    findUsersAndNotify();
}, {
    scheduled: false
});

//home
app.get('/', (req, res) => {
    res.send('Site is live!');
})

//login
app.post('/login', async function (req, res) {
    try {
        var user = req.body;
        //console.log(user);
        var result = await login(user.userName, user.password, user.token);
        res.send(result);

    } catch (e) {
        console.log(e);
        res.status(500).send(e);
    }
})

//logout
app.post('/logout', async function (req, res) {
    try {
        var user = req.body;
        var result = await logout(user.userName);
        res.send(result);

    } catch (e) {
        res.status(500).send(e);
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, function () {
    console.log(`App listening on port ${PORT}!`);
    task.start();
});