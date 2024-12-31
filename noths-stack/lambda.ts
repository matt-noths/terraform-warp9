import {APIGatewayProxyHandler} from 'aws-lambda';
import {DynamoDB} from "aws-sdk";

const dynamoDB = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
    await dynamoDB.update({
        TableName: 'HelloWorldCounter',
        Key: {id: 'visits'},
        UpdateExpression: 'ADD #count :incr',
        ExpressionAttributeNames: {'#count': 'count'},
        ExpressionAttributeValues: {':incr': 1}
    }).promise();

    const result = await dynamoDB.get({
        TableName: 'HelloWorldCounter',
        Key: {id: 'visits'}
    }).promise();

    const count = result.Item?.count || 0;

    return {
        statusCode: 200,
        body: JSON.stringify({message: 'Hello, World!', count})
    };
};
