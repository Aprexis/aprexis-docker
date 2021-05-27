# Overview

This document describes the lessons learned when developing the Aprexis docker project.

# Background

Aprexis was not set up initially for use in docker. An attempt was made previously to allow it to run under docker, but to my knowledge, it was never fully implemented. The only part of it that made it into the Aprexis platform project was an environment configuration for development.

Getting the system set up for doing local development without docker is complicated, especially if you want all of the pieces. In particular, it requires the following:

- Git
- Ruby
- Ruby Bundler
- Postgres database
- Redis database
- Aprexis platform repository
- Aprexis API repository
- Aprexis API UI repository
- An anonymized data dump

The Aprexis platform is known to be compatible with Ruby 2.5.3 as of this writing.

The development environment is set up to expect a username equal to the logged in user. This user needs to be able to create databases, so at least some privileges have to be set. No password is used, so the database needs to be configured to allow access from localhost without a password.

Redis isn't complicated to set up, but it isn't used by as many Bear Code projects, so it may be unfamiliar.

The anonymized data dump is basically a copy of production data that has had personally identifying information removed or replaced. It is stored on S3. The Aprexis system doesn't have a seed capability, which means that using it requires either the data dump or a lot of manual work to set something up.

# Docker Project

The Aprexis docker project is in a separate repository. It isn't required by the platform or API, but can make getting set up on a new system simpler. Only Git and Docker are required.

There are shortcuts using Make and Bash (both generally available on Linux, at least). These aren't strictly required, but will make getting set up much easier.

The docker project has two Docker compose files:

1. docker-compose-platform.yml
2. docker-compose-api.yml

The platform version provides a complete development environment for the original Aprexis platform. It provides the background tasks with Resque and the extended SOLR search capabilities.

The API version adds the API and its accompanying user interface. You only need the API and API UI repositories if you are going to use this version.

## Setup

Docker requires that all files to be placed into its containers be in folder hierarchy anchored in the folder containing the docker files themselves. You cannot use '..' references or absolute paths (or symbolic links using such).

One way to handle this would have been to make the Aprexis docker project contain the other projects as sub-modules. When I did this for Aspenti, I was the only developer and changes to the structure of the existing repositories wasn't going to affect anyone else. I don't remember if there were any such changes, but I chose not to go this route for Aprexis.

Instead, the Aprexis docker project just requires that you clone the code repositories under it. Git in the docker project ignores those folders. You can even move an existed cloned repository into it.

There is more information in the README markdown for the Aprexis docker project, but to get started the first time, you do the following:

1. Clone the Aprexis docker project
2. Enter the Aprexis docker project
3. Clone the Aprexis platform (Rails 5) project
4. Clone the Aprexis API project
5. Clone the Aprexis API UI project
6. Download the anonymized Aprexis data
7. Build the desired variety
8. Build the database
9. Launch the Aprexis system
10. Shutdown docker when done

## Configuration

Rails is configured for different cases through the use of what it calls 'environments'. The four most important environments used by the platform are:

1. production
2. staging
3. development
4. test

The shell environment variable `RAILS_ENV` is used to tell Rails which environment it should use. If `RAILS_ENV` is not explicitly set, it defaults to `development` when running the application, or `test` when running the tests.

The original set up for docker added an `development_docker` environment. My first thought was to create an additional `test_docker` environment, but it turns out that this doesn't work.

You can't use the standard Docker rake tasks for setting up for testing using any environment other than `test` - it appears there are places where this is hardcoded into the tasks. The result is that setting `RAILS_ENV` to `test_docker` creates confusion as the `test` environment file is read and used. I can't remember if there is some mixing of the two, but it doesn't really matter since you won't get what you want either way.

An additional complication was that I didn't want a developer to have to use docker at all. Ideally, I also wanted to allow for the case where docker was being used to provide the supporting postgres and Redis (and optionally SOLR).

When running development without docker, everything is running on localhost. The original `development` and `test` environments were set up to use this. For docker, however, localhost is always the current container. Each of the major pieces run in their own containers. This requires that the configuration specify the appropriate container hostname, not localhost.

The environment configurations can pull information from the shell environment through the use of the `ENV` object. So, the solution was to use a shell environment variable to specify the hostnames, using localhost as a default if the environment variable isn't set. Thus, for docker, the environment variables can be set by the containers. When run outside of docker, the environment variables can be omitted and localhost is used.

Great, problem solved. Except that it wasn't. It turns out that there are a number of additional configuration files that get read during the start up of the application and some of those also have enviroment specific settings - i.e., they have entries like `development` and `test` as well. Okay, so just change those to use the environment variables.

That worked for some files, but not others. In particular, it worked in the `database.yml` file, which is read by Rails, but not things like `resque.yml`, which is used to tell Resque (background task handler) how to find Redis and is read by an initializer that is in the Aprexis platform project.

The problem is that if you just load YAML files directly using the obvious `YAML.load_file` method, it doesn't understand the `<%= ... %>` syntax that can be used in `database.yml`. Instead, you have to first load the file using `ERB` to handle the substitutions and then read the results of that as YAML using something like this:

```
template = ERB.new File.new(file_path).read
yaml = YAML.load template.result(binding)
```

There were a number of YAML files that needed to be updated, not just the Resque one.

Trying to use docker to supply the postgres and Redis databases when running the application or tests on the host ran into one more issue: the postgres user. The `development` and `test` environments didn't specify the username in the connection parameters, which meant that it was using the username of the user logged into the host (`ibrown` in my case). However, in docker, the logged in user is `root`.

Actually, with docker, there is no really good reason to create a user - the standard `postgres` administrative user can be used. Again, the environment variables came into play: for docker, the username is set via the environment variable to `postgres`, with the environment configuration having a default of the host logged in user's username.
