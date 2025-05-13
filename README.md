# Dockerized Aprexis

This project allows a user or developer to run the Aprexis system locally using docker. It requires a working docker installation.


## Quick Start

Short version of the setup steps. A more detailed version, with background info and options, is below.

#### 1. Clone the repositories

In the root dir of your checkout of this repo
```
git clone git@github.com:Aprexis/aprexis-engine.git
git clone git@github.com:Aprexis/aprexis-platform-5.git
git clone git@github.com:Aprexis/aprexis-api.git
git clone git@github.com:Aprexis/aprexis-api-ui.git
git clone git@github.com:Aprexis/aprexis-etl.git
cp env.example .env
```
#### 2. Create Github access token

Create a classic access token to allow you to pull the aprexis-engine gem from Github. To do this:

1. Log into your account on github.com
2. Click on your picture (or whatever icon it has to display your account) and select Settings from the pulldown
3. Click on Developer Settings (at the bottom of the settings pages)
4. Expand the entry Personal access tokens
5. Select Tokens (classic)
6. Click Generate new token
7. My personal token doesn't expire, but that's because we're currently using it for deploying to the production, staging, and demo machines. It is a pain to deal with expired tokens, so I won't force you to set an expiration, but you can
8. I haven't tried to figure out what the minimum set of permissions needed is. I know that this set works: admin:enterprise, admin:gpg_key, admin:org, admin:org_hook, admin:public_key, admin:repo_hook, admin:ssh_signing_key, audit_log, codespace, delete:packages, delete_repo, gist, repo, user, workflow, write:discussion, write:package

#### 3. Update .env

Update the `.env` file.
- Set the `APREXIS_USERNAME` to your github username that owns the access token just created.
- Set `APREXIS_ENGINE_TOKEN` to the access token.

Then:
```
source .env
```

#### 4. Get a database dump

Get a `.gz` database dump from S3 or Google drive. It will be named something like `aprexis_anonymized_YYYY-MM-DD.sql.gz`. Put it in the `aprexis-data/database` dir.

#### 5. Modify Gemfiles for local development

Edit theses two files:

```
aprexis-api/Gemfile
aprexis-platform-5/Gemfile
```

Set the `aprexis-engine` gem line in both files to this:
 ```
 gem 'aprexis-engine', path: '../aprexis-engine'
 ```

#### 6. Build and run the project

To build it from the new-style anonymized data, run:

```bash
make build_engine
make load_anonymized_db
make build
make bundle_install
make up
```

To build it from the old-style full database dump anonymized data, run:

```bash
make build_engine
make new_db
make build
make bundle_install
make up
```

#### 7. Go to the apps

- Platform: http://localhost:3000
- API UI:  http://localhost:3500
- API:  http://localhost:3250


## Varieties

There are two setups for running the Aprexis system:

1. The basic platform, consisting of the Rails application and the Resque system, along with the supporting databases and the SOLR search engine.

2. The complete application, which adds the API and the user interface for the API to the basic platform.

The variety is controlled by the environment variable APREXIS_VARIETY, which can take the values:

- platform
- api (the default)

## Setup

Getting the system set up is easier with docker than it is without, but it still requires some work. The various project repositories are not linked, so you will have to clone each of them independently. However, due to restrictions imposed by docker, you will need to clone the docker project first and then put the remaining projects under that.

Here are the steps:

1. Clone the Aprexis docker project
2. Enter the Aprexis docker project
3. Clone the Aprexis engine project
4. Clone the Aprexis platform (Rails 5) project
5. Clone the Aprexis API project
6. Clone the Aprexis API UI project
7. Set up the environment and configuration
8. Download the anonymized Aprexis data
9. Build the desired variety
10. Build the database
11. Launch the Aprexis system
12. Shutdown docker when done

The application, API, the UI for API are all set up to automatically load changes (although you will need to refresh the browser to get the UI changes into a running tab).

### Clone the Aprexis docker project

Use the following command to do the clone:

```bash
git clone git@github.com:Aprexis/aprexis-docker.git
```

### Enter the Aprexis docker project

```bash
cd aprexis-docker
```

All of the remaining steps should be performed in the **aprexis-docker** folder.

### Clone the Aprexis engine project

In the **aprexis-docker** folder, use the following command to do the clone:

```bash
git clone git@github.com:Aprexis/aprexis-engine.git
```

### Clone the Aprexis platform (Rails 5) project

In the **aprexis-docker** folder, use the following command to do the clone:

```bash
git clone git@github.com:Aprexis/aprexis-platform-5.git
```

### Clone the Aprexis API project

In the **aprexis-docker** folder, use the following command to do the clone:

```bash
git clone git@github.com:Aprexis/aprexis-api.git
```

### Clone the Aprexis API UI project

In the **aprexis-docker** folder, use the following command to do the clone:

```bash
git clone git@github.com:Aprexis/aprexis-api-ui.git
```

### Set up the environment and configuration

There are two parts to this:

1. Create an **.env** file
2. Configure access to the Aprexis engine

#### Create an **.env** file

In the **aprexis-docker** folder, create a file named **.env** to set up the docker environment. You can start from the file called **env.example**.

See the section on environment variables for a full list.
#### Configure access to the Aprexis engine

The Aprexis engine is a Ruby gem project that is installed by the platform and API Gemfiles. There are two ways that the gem can be used:

1. Installing from Github
2. Installing from the local source

Staging and production will always install from Github. Developers can either use Github or local source. However, even if you are planning to use the local source, you should configure access to the Github installation
and maintain that access as described below.

##### Installing from Github

The Aprexis engine is a private repository on Github, which allows us to control access to the source and installed gem. To install from Github, you will need what is called a 'fine-grained access token'. These are secret
keys used to allow access to Github without a password. They expire after a configurable period, so you will have to occasionally create a new one and update your configuration.

To create an fine-grained access token, follow the instructions in https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token.

Use these values:
- **Name**: enter a value that will let you know what the access token is for. Example: Aprexis engine
- **Expiration**: select or enter a time period or specific date after which the token will expire. Example: Custom - 01/01/2024 (or whatever next year is)
- **Resource owner**: Aprexis
- **Repository access**: Only select repositories
- **Selected repositories**: aprexis-engine
- **Permissions**: select what permissions the token should grant. By default, you should have read access, but you might also want to enable read access to the Github workflows.

Once you click on Generate token, the access token will be created and presented to you. Make sure you do the steps below before you navigate away from the presentation page. There is no way on Github to recover the token
after you leave the page. You will have to generate a new one.

Add the following line to **.bashrc** or a similar file that is executed when you login:

```bash
export APREXIS_ENGINE_TOKEN=<your fine-grained access token>
```

Set the **APREXIS_USERNAME** and **APREXIS_ENGINE_TOKEN** in the **.env** file. These values are used to install the gem in the docker containers.

- **APREXIS_USERNAME**: your Github username.
- **APREXIS_ENGINE_TOKEN**: your fine-grained access token.

If you use the Ruby bundler on the host, run the following command in the **aprexis-platform** and **aprexis-api** folders (this is also documented in those projects):

```bash
bundle config --local GITHUB__COM x-access-token:$APREXIS_ENGINE_TOKEN
```

The command depends on the value set in your **.bashrc** or similar shell set up file. If you change that value (as after creating a new token when the old one expires), you will need to run this command again.

The platform and API project **Gemfile** files will need to be set up to pull the engine gem from Github. The line that specifies the gem should look like:

```ruby
gem 'aprexis-engine', git: 'https://github.com/Aprexis/aprexis-engine.git', branch: <branch name>, tag: <release tag>
```

The branch will be one of:
- **master**: for official releases, used for production deployments.
- **development**: for alpha releases, used for staging deployments.
- <feature branch>: for development feature pre-releases.

The release tag will be whatever tagged release version you want to use.

#### Installing from the local source

To install from the local source, as when you are working on the engine itself, change the line that specifies the gem in the **Gemfile** in the platform and API projects to look like:

```bash
gem 'aprexis-engine', path: '../aprexis-engine'
```

### Download the anonymized Aprexis data

To really be able to run the system, you will need this data. In theory, you could set up an Aprexis administrator user and then use the application to create health plans, pharmacies, etc. That's beyond the scope of this document. In general, it is better to use the anonymized production data.

The data is kept on Amazon S3. You are supposed to be able to run the following commands to pull it down:

```bash
cd aprexis-data/database
wget https://aprexis-test-data.s3-us-west-2.amazonaws.com/<latest anonymized data>.sql.gz
cd ..
```

S3 may not grant this access. If you have an AWS login for the Aprexis project, you can download the file directly from S3 using the AWS console. Place it into the **aprexis-data/database** folder.

You do not need to unzip this file after downloading it.

### Build the desired variety

After setting APREXIS_VARIETY (or leaving it unset to use the default), build the project by running:

```bash
make build
```

This will take a while as it will need to download docker images. Make sure it completes successfully before trying any of the other steps.

### Build the database

You can build a new, clean copy of the database using the following command:

```bash
make new_db
```

If you don't have an existing database, you may see some errors. If you haven't downloaded the anonymized data, then this will simply build the database and create the table schema within it. That won't take too long. If, however, you do have the anonymized data, the full process will take quite a while and will produce quite a bit of output. This step does the following:

1. Drops the existing database if any
2. Create a new, empty database
3. Loads the anonymized data into the new database, which creates all of the tables and copies data into them. As the file is quite large, this will take a while.
4. Migrates the database to the latest schema. Depending on how out-of-date the anonymized data is, this could be a quick process or could take a while.
5. Enables all users with the password *Password!*. This will take a while and will echo a lot of SQL UPDATE statements as the code works it way through each of the users.
6. Indexes the SOLR search engine - tihs allows finding things like medications in the application. This also takes a while.

### Launch the Aprexis system

All of the containers for the current variety can be started using the command:

```bash
make up
```

You can stop the system by hitting ctrl-C. This will partially clean things up, but it is best to do the next step to ensure that all of the containers are down.

### Shutdown docker when done

You can clean up any stranded containers by running:

```bash
make down
```

# Using the System

Once the system has been built, you generally don't need to rebuild it unless you make changes to the docker setup. Unless you get new data or want to restart from a clean slate, you shouldn't need to create a new database even if you do rebuild the system.

Both Rails and React are set up to pick up changes while running. The browser generally needs to be refreshed to cause it to load the new version, but you won't lose context when you do.

## Running the system

Starting and stopping the system after it has been built only requires the last two steps from the setup.

To start:

```bash
make up # (runs in foreground, ctrl-C to stop)
make upd # (runs in background)
```

To stop:

```bash
make down # (cleans up after ctrl-C in the foreground or to shutdown a background run)
```

## Testing the system

To run the platform and API tests, you can start a shell running on the appropriate container. The commands for doing these are:

```bash
make platform_shell # (to test the original Rails platform)
make api_shell # (to test the API)
make engine_shell # (to test the Engine)
```

## Pull all latest code

Issues a `git pull` on all of the aprexis-* repositories used by docker-compose. This will pull whatever branch is currently checked out locally for each repository.

If the branch has local changes, those changes are stashed to avoid potential conflicts. Any stashed changes will need to be unstashed manually.

```bash
make git_pull
```

## Running the system in a hybrid fashion

You can use docker to provide Postgres, Redis, and optionally SOLR. If you've done a build of the system, there are four useful Make commands available:

1. `make postgres` - runs Postgres in a container, with its 5432 port mapped to the host.
2. `make redis` - runs Redis in a container, with its 6379 port mapped to the host.
3. `make solr` - runs SOLR in a container, with its 8983 port mapped to the host.
4. `make support` - runs all three of the above. Actually, the `make solr` command effectively does this, so you could use that instead.

SOLR is provided by the platform, so you need to do the build to run this. Postgres and Redis are simply standard docker images, so you could run these manually if you prefer.

## Environment Variables

The complete list of environment variables added to support docker is:

**APREXIS_HOST_IP**- specifies the IP address to access the host machine when running in docker. Default is 172.17.0.1.

**APREXIS_PLATFORM_PORT** - specifies the port used by the application. Default is 3000.

**APREXIS_API_PORT** - specifies the port used by the API. Default is 3250.

**APREXIS_API_UI_PORT** - specifieds the port used by the UI for the API. Default is 3500.

**APREXIS_POSTGRES_HOST** - specifies the hostname of the Postgres database. Default is localhost.
**APREXIS_POSTGRES_USERNAME** - specifies the username to use to log into the Postgres database. Default is the username for the user logged into the host.
**APREXIS_POSTGRES_PORT** - specifies the host port used by the Postgres database. Changing this will allow you to run the docker Postgres database alongside one running on the host. Default is 5432.

**APREXIS_REDIS_HOST** - specifies the hostname of the Redis database. Default is localhost.
**APREXIS_REDIS_PORT** - specifies the host port used by the Redis database. Changing this will allow you to run the docker Redis database alongside one running on the host. Default is 6379.
**APREXIS_REDIS_DEVELOPMENT_RESQUE_URL** - specifies the URL used to connect Resque to the development Redis database. The default is localhost:6379:0.
**APREXIS_REDIS_TEST_RESQUE_URL** - specifies the URL used to connect Resque to the test Redis database. Default is localhost:6379:8.
**APREXIS_REDIS_DEVELOPMENT_SESSION_URL** - specifies the URL used by the platform to store its HTTP session information in the development Redis database. Default is redis://localhost:6379/1.
**APREXIS_REDIS_TEST_SESSION_URL** - specifies the URL used by the platform to store its HTTP session in the test Redis database. Default is redis://localhost:6379/2.

**APREXIS_SOLR_HOST** - specifies the hostname of the SOLR search engine. Default is localhost.
**APREXIS_SOLR_PORT** - specifies the host port of the SOLR search engine. Changing this will allow to run the docker SOLR alongside one running on the host. Default is 8983.

**APREXIS_USERNAME** - specifies the Github username to use to get the Aprexis engine releases
**APREXIS_ENGINE_TOKEN** - specifies the Github fine-grained access token to use to get the Aprexis engne releases
