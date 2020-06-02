# README

This project uses:
rails version 6.0.3
ruby version 2.6.6 and
postgreSQL as database

A brief introduction:

This app allows user to create some tools with a `name` and a `language` provided by the user.
As soon as the user creates a new tool, the application conducts a search for a file (`<tool_name>.<language>.master.json` or `<tool_name>.<language>.json`) on gitHub.
This file's content is fetched and stored in tool's `json_spec` field. Along with it we generate some keys and send these keys to Lokalise.

Whenever a user adds new translations to Lokalise, (s)he comes to this app and use the _update translation_ feature.

In this feature we fetch the translations for all the keys and with the translations we create a new file `<tool_name>.<language>.json`.
This new file is pushed to github on a separate branch and a PR is created for that as well.

We have setup a webhook (URL: https://coding_challenge.ngrok.io/tools/webhook) on gitHub so that whenever the branch is merged it makes a request to our app and we update the json_spec for the respective tool.
