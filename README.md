Nginx
=====

Minimal nginx docker with environment configurable domain name and proxy settings for a meteor app.

## Supported Docker versions

This image is supported on Docker version `1.13` and newest.

## Configuration
Expecting the following environment variables

```
WEB_HOST
WEB_SSL
METEOR_APP  [name of your meteor app running in 3000, if it is available, default location will go to that.]

```
