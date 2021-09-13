
var admin = require("firebase-admin");

var serviceAccount = require("./firebase_creds.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const sendNotification = async (notification) => {
    try {
        await admin.messaging().send(notification);
    }
    catch (e) {
        return Promise.reject(e);
    }
}
sendNotification(notification).catch(e => console.log(e));
module.exports = {
    sendNotification
}