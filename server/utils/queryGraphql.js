const fetch = require('node-fetch');

queryGraphql = async ({ query, variables }) => {
    //console.log(variables.userFields.userName);
    try {
        let gql = await fetch("https://parseapi.back4app.com/graphql", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-Parse-Application-Id": "",
                "X-Parse-Master-Key": "",
                "X-Parse-Client-Key": ""
            },
            body: JSON.stringify({
                query: query
                ,
                variables: variables
            })
        })
        gql = await gql.json();
        //console.log("GQL: ", gql)
        if (gql.errors) {
            return Promise.reject(gql.errors[0].message);
        }
        return Promise.resolve(gql.data);
    }
    catch (err) {
        return Promise.reject(err)
    }
}

module.exports = queryGraphql;