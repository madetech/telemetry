require 'json'
require 'aws-sdk-sqs'

def handler(event:, context:)
    sqs = Aws::SQS::Client.new(region: 'eu-west-2')
    
    case(event['path'])
    when "/pipelines/build-failed"
      sqs.send_message(
        queue_url: ENV['QUEUE_URL'], 
        message_body: { status: :failed, trace: event['headers']['X-Amzn-Trace-Id'] }.to_json, 
        message_group_id: "1"
      )
    when "/pipelines/build-passed"
      sqs.send_message(
        queue_url: ENV['QUEUE_URL'], 
        message_body: { status: :passed, trace: event['headers']['X-Amzn-Trace-Id'] }.to_json, 
        message_group_id: "1"
      )
    else
      return {
        statusCode: 404, 
        body: {}.to_json, 
        headers: {
            'Content-Type': 'application/json'
        }
      }
    end
    
    {
        statusCode: 200, 
        body: { done: true }.to_json, 
        headers: {
            'Content-Type': 'application/json'
        }
    }
end

