# Stackato Github Webhook

## Webhook URL
https://git-webhook.activestate.com/payload

## How does it work?
The webhook https://git-webhook.activestate.com/payload has been added in the `Webhooks & Services` section of the Stackato Github repository. When you open or update a pull request on it, Github will trigger the webhook. The webhook will then determine what components to build and trigger the right components jenkins jobs by using the map `component path -> component jenkins job` given in the file config.yaml.

## Where does it live?
It's currently hosted on Stackato at the address https://api.activestate.com.

## How to push it?
```
$ stackato login --target api.activestate.com YOUR_USERNAME
$ stackato push -n
```

