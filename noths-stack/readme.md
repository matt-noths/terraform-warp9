Just noodling about with TF, trying to get a few services talking to each other.

I wanted to use the NOTHS modules e.g.
```terraform
module "env" {
  source = "app.terraform.io/notonthehighstreet/noths-env-vars/module"
  version = "~> 1.5"
  env_id = "qa" 
}
```

But I get a "401 Unauthorized" error when trying to import it. I have [asked on Slack about this](https://noths.slack.com/archives/CDK6JKDGX/p1735642030644309).

# todo

- [ ] Create a "hello world" lambda
- [ ] Create an API Gateway
  - [ ] hook up `/hello` to the lambda
- [ ] Create a dynamo instance
- [ ] Create a web page that:
  - [ ] reads from dynamo
  - [ ] writes to dynamo
