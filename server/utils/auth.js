const queryGraphql = require('./queryGraphql');

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

const login = async (userName, password, firebaseId) => {
  try {
    const users = await queryGraphql({
      query: `
            query($userName:String!){
                users(where:{username:{equalTo:$userName}}){
                  count
                  edges{
                    node{
                      objectId
                    }
                  }
                }
            }
            `,
      variables: {
        userName
      }
    });

    if (users.users.count == 0) {
      const newUser = await queryGraphql({
        query: `
                mutation($userName:String!, $password:String!, $firebaseId:String){
                    createUser(input:{fields:{
                      username: $userName,
                      password: $password,
                      firebaseId: $firebaseId
                    }}){
                      user{
                        objectId
                      }
                    }
                  }
                `,
        variables: {
          userName,
          password,
          firebaseId
        }
      });
      await updateTimestamp(newUser.createUser.user.objectId);
      return Promise.resolve(newUser.createUser.user.objectId);
    }
    else {
      const user = await queryGraphql({
        query: `
                mutation($userName:String!, $password:String!){
                    logIn(input:{username:$userName, password:$password}){
                      viewer{
                        user{
                          objectId
                        }
                      }
                    }
                  }
                `,
        variables: {
          userName,
          password,
        }
      });
      if (user.logIn == null) {
        return Promise.reject('Invalid username/password');
      }
      const userId = user.logIn.viewer.user.objectId;
      await updateTimestamp(userId);
      return Promise.resolve(user.logIn.viewer.user.objectId);
    }
  }
  catch (e) {
    return Promise.reject(e);
  }
}
const logout = async (userName) => {
  try {
    const user = await queryGraphql({
      query: `
      query($userName:String!){
        users(where:{username:{equalTo:$userName}}){
          count
          edges{
            node{
              objectId
            }
          }
        }
      }
      `,
      variables: {
        userName
      }
    });
    if (user.users.count == 0) {
      return Promise.reject('Invalid username');
    }
    const userId = user.users.edges[0].node.objectId;
    const sessions = await queryGraphql({
      query: `
      query($userId:ID!){
        sessions(where:{user:{have:{objectId:{equalTo:$userId}}}}){
          edges{
            node{
              objectId
            }
          }
        }
      }
      `,
      variables: {
        userId
      }
    });
    let n = sessions.sessions.edges.length;
    for (let i = 0; i < n; i++) {
      await queryGraphql({
        query: `
        mutation($sessionId:ID!){
          deleteSession(input:{id:$sessionId}){
            session{
              objectId
            }
          }
        }
        `,
        variables: {
          sessionId: sessions.sessions.edges[i].node.objectId
        }
      });
    }

    //delete user
    await queryGraphql({
      query: `
      mutation($userId:ID!){
        deleteUser(input:{id:$userId}){
          user{
            objectId
          }
        }
      }
      `,
      variables: {
        userId
      }

    });
    return Promise.resolve("logged out");
  } catch (e) {
    return Promise.reject(e);
  }


}
module.exports = {
  login,
  logout
}