const axios = require('axios');
const queryGraphql = require('./queryGraphql');

const { sendNotification } = require('./firebase');

const findUsersAndNotify = async () => {
    try {
        const users = await queryGraphql({
            query: `
            query{
                users{
                  edges{
                    node{
                      objectId
                      username
                      firebaseId
                      timeStamp
                    }
                  }
                }
              }
            `,
            variables: {}
        });
        for (let i = 0; i < users.users.edges.length; i++) {
            await updateTimestamp(users.users.edges[i].node.objectId);
            let user = await fetchUser(users.users.edges[i].node.username);
            let followingIds = await fetchFollowings(user.login, user.following);
            let events = [];
            for (let j = 0; j < followingIds.length; j++) {
                let userEvents = await fetchEvents(followingIds[j], users.users.edges[i].node.timeStamp);
                events = events.concat(userEvents);
                //console.log(j);
            }
            let notifications = await generateNotificaitons(events, users.users.edges[i].node.firebaseId);
            console.log(notifications);
            for (let j = 0; j < notifications.length; j++) {
                await sendNotification(notifications[j]);
            }
        }
        return Promise.resolve();
    }

    catch (e) {
        return Promise.reject(e);
    }
}

const updateTimestamp = async (userId) => {
    try {
        //console.log(userId);
        const d = new Date();
        //console.log(d);
        const user = await queryGraphql({
            query: `
        mutation($userId:ID!, $timeStamp:Date!){
          updateUser(input:{id:$userId fields:{timeStamp:$timeStamp}}){
            user{
              objectId
            }
          }
        }
        `,
            variables: {
                userId,
                timeStamp: d.toISOString()
            }
        });
        return Promise.resolve(user.updateUser.user.objectId);
    } catch (e) {
        return Promise.reject(e);
    }
}

const fetchUser = async (userName) => {
    try {
        const options = {
            method: 'GET',
            url: `https://api.github.com/users/${userName}`,
            headers: {
                Authorization: `token --OAuth token--`
            }
        }
        const response = await axios(options);
        return Promise.resolve(response.data);
    }
    catch (e) {
        return Promise.reject(e);
    }
}

const fetchFollowings = async (userName, count) => {
    try {
        let followingIds = []
        for (let i = 0; i * 100 < count; i++) {
            let options = {
                method: 'GET',
                url: `https://api.github.com/users/${userName}/following`,
                params: {
                    per_page: 100,
                    page: i + 1
                },
                headers: {
                    Authorization: `token --OAuth token--`
                }
            }
            let response = await axios(options);
            followingIds = followingIds.concat(response.data.map(user => user.login));
        }
        return Promise.resolve(followingIds);
    }
    catch (e) {
        return Promise.reject(e);
    }
}

const fetchEvents = async (userName, timeStamp) => {
    try {
        let options = {
            method: 'GET',
            url: `https://api.github.com/users/${userName}/events`,
            headers: {
                Authorization: `token --OAuth token--`
            }
        }
        let response = await axios(options);
        var d = new Date(timeStamp);
        //d.setDate(d.getDate() - 1);
        let i = 0;
        while (i < response.data.length && new Date(response.data[i].created_at) >= d) {
            i++;
        }
        let events = [];
        let allowedTypes = ['ForkEvent', 'CreateEvent', 'WatchEvent', 'FollowEvent'];
        for (let j = 0; j < i; j++) {
            if (allowedTypes.includes(response.data[j].type)) {
                events.push(response.data[j]);
            }
        }
        return Promise.resolve(events);
    }
    catch (e) {
        return Promise.reject(e);
    }
}

const generateNotificaitons = async (events, firebaseId) => {
    try {
        let notifications = [];
        for (let i = 0; i < events.length; i++) {
            let event = events[i];
            let title = "";
            let body = "";
            if (event.type == 'WatchEvent') {
                title = "Starred";
                body = `${event.actor.login} started watching ${event.repo.name}`;
            }
            else if (event.type == 'ForkEvent') {
                title = "Forked";
                body = `${event.actor.login} forked ${event.repo.name}`;
            }
            else if (event.type == 'CreateEvent') {
                title = "Created";
                body = `${event.actor.login} created ${event.payload.ref_type} ${event.payload.ref} in ${event.repo.name}`;
            }
            else if (event.type == 'FollowEvent') {
                title = "Followed";
                body = `${event.actor.login} started following ${event.payload.target.login}`;
            }
            notifications.push({
                notification: {
                    title: title,
                    body: body,
                    image: event.actor.avatar_url,
                },
                android: {
                    notification: {
                        title: title,
                        body: body,
                    },
                    priority: "high"
                },
                token: firebaseId
            })
        }
        return Promise.resolve(notifications);
    }
    catch (e) {
        return Promise.reject(e);
    }
}
module.exports = {
    findUsersAndNotify
}
//findUsersAndNotify().then(() => { }).catch(e => console.log(e));