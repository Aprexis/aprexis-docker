# Dockerized Aprexis

This project allows a user or developer to run the Aprexis system locally using docker. It requires a working docker installation.

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
3. Clone the Aprexis platform (Rails 5) project
4. Clone the Aprexis API project
5. Clone the Aprexis API UI project
6. Download the anonymized Aprexis data
7. Build the desired variety
8. Build the database
9. Launch the Aprexis system
10. Shutdown docker when done

The application, API, the UI for API are all set up to automatically load changes (although you will need to refresh the browser to get the UI changes into a running tab). If you are wish to restart, you can generally use just steps 2, 9, and 10.

### Clone the Aprexis docker project

Use the following command to do the clone:

`git clone git@github.com:Aprexis/aprexis-docker.git`

### Enter the Aprexis docker project

`cd aprexis-docker`

All of the remaining steps should be performed in the **aprexis-docker** folder.

### Clone the Aprexis platform (Rails 5) project

In the **aprexis-docker** folder, use the following command to do the clone:

`git clone git@github.com:Aprexis/aprexis-platform-5.git`

NOTE: for now, the only branch of this project that works is the development branch, or branches off of that created
      after May 27th, 2021.

### Clone the Aprexis API project

In the **aprexis-docker** folder, use the following command to do the clone:

`git clone git@github.com:Aprexis/aprexis-api.git`

This project is only required if you want to use or work on the API. If you are going to be running the basic platform, you cna omit this step.

### Clone the Aprexis API UI project

In the **aprexis-docker** folder, use the following command to do the clone:

`git clone git@github.com:Aprexis/aprexis-api-ui.git`

This project is only required if you want to use or work on the API. If you are going to be running the basic platform, you can omit this step.

### Download the anonymized Aprexis data

To really be able to run the system, you will need this data. In theory, you could set up an Aprexis administrator user and then use the application to create health plans, pharmacies, etc. That's beyond the scope of this document. In general, it is better to use the anonymized production data.

The data is kept on Amazon S3. You are supposed to be able to run the following commands to pull it down:

```
cd aprexis-data
wget https://aprexis-test-data.s3-us-west-2.amazonaws.com/<latest anonymized data>.sql.gz
cd ..
```

S3 may not grant this access. If you have an AWS login for the Aprexis project, you can download the file directly from S3 using the AWS console. Place it into the **aprexis-data** folder.

You do not need to unzip this file after downloading it.

### Build the desired variety

After setting APREXIS_VARIETY (or leaving it unset to use the default), build the project by running:

`make build`

This will take a while as it will need to download docker images. Make sure it completes successfully before trying any of the other steps.

### Build the database

You can build a new, clean copy of the database using the following command:

`make new_db`

If you don't have an existing database, you may see some errors. If you haven't downloaded the anonymized data, then this will simply build the database and create the table schema within it. That won't take too long. If, however, you do have the anonymized data, the full process will take quite a while and will produce quite a bit of output. This step does the following:

1. Drops the existing database if any
2. Create a new, empty database
3. Loads the anonymized data into the new database, which creates all of the tables and copies data into them. As the file is quite large, this will take a while.
4. Migrates the database to the latest schema. Depending on how out-of-date the anonymized data is, this could be a quick process or could take a while.
5. Enables all users with the password *Password!*. This will take a while and will echo a lot of SQL UPDATE statements as the code works it way through each of the users.
6. Indexes the SOLR search engine - tihs allows finding things like medications in the application. This also takes a while.

### Launch the Aprexis system

All of the containers for the current variety can be started using the command:

`make up`

You can stop the system by hitting ctrl-C. This will partially clean things up, but it is best to do the next step to ensure that all of the containers are down.

### Shutdown docker when done

You can clean up any stranded containers by running:

`make down`

# Using the System

Once the system has been built, you generally don't need to rebuild it unless you make changes to the docker setup. Unless you get new data or want to restart from a clean slate, you shouldn't need to create a new database even if you do rebuild the system.

Both Rails and React are set up to pick up changes while running. The browser generally needs to be refreshed to cause it to load the new version, but you won't lose context when you do.

## Running the system

Starting and stopping the system after it has been built only requires the last two steps from the setup.

To start:

`make up` (runs in foreground, ctrl-C to stop)
`make upd` (runs in background)

To stop:

`make down` (cleans up after ctrl-C in the foreground or to shutdown a background run)

## Testing the system

To run the platform and API tests, you can start a shell running on the appropriate container. The commands for doing these are:

`make platform_shell` (to test the original Rails platform)
`make api_shell` (to test the API)

## Running the system in a hybrid fashion

You can use docker to provide Postgres, Redis, and optionally SOLR. If you've done a build of the system, there are four useful Make commands available:

1. `make postgres` - runs Postgres in a container, with its 5432 port mapped to the host.
2. `make redis` - runs Redis in a container, with its 6379 port mapped to the host.
3. `make solr` - runs SOLR in a container, with its 8983 port mapped to the host.
4. `make support` - runs all three of the above. Actually, the `make solr` command effectively does this, so you could use that instead.

SOLR is provided by the platform, so you need to do the build to run this. Postgres and Redis are simply standard docker images, so you could run these manually if you prefer.

## Environment Variables

The complete list of environment variables added to support docker is:

`APREXIS_PLATFORM_PORT` - specifies the port used by the application. Default is 3000.

`APREXIS_API_PORT` - specifies the port used by the API. Default is 3250.

`APREXIS_API_UI_PORT` - specifieds the port used by the UI for the API. Default is 3500.


`APREXIS_POSTGRES_HOST` - specifies the hostname of the Postgres database. Default is localhost.
`APREXIS_POSTGRES_USERNAME` - specifies the username to use to log into the Postgres database. Default is the username for the user logged into the host.
`APREXIS_POSTGRES_PORT` - specifies the host port used by the Postgres database. Changing this will allow you to run the docker Postgres database alongside one running on the host. Default is 5432.

`APREXIS_REDIS_HOST` - specifies the hostname of the Redis database. Default is localhost.
`APREXIS_REDIS_PORT` - specifies the host port used by the Redis database. Changing this will allow you to run the docker Redis database alongside one running on the host. Default is 6379.
`APREXIS_REDIS_DEVELOPMENT_RESQUE_URL` - specifies the URL used to connect Resque to the development Redis database. The default is localhost:6379:0.
`APREXIS_REDIS_TEST_RESQUE_URL` - specifies the URL used to connect Resque to the test Redis database. Default is localhost:6379:8.
`APREXIS_REDIS_DEVELOPMENT_SESSION_URL` - specifies the URL used by the platform to store its HTTP session information in the development Redis database. Default is redis://localhost:6379/1.
`APREXIS_REDIS_TEST_SESSION_URL` - specifies the URL used by the platform to store its HTTP session in the test Redis database. Default is redis://localhost:6379/2.

`APREXIS_SOLR_HOST` - specifies the hostname of the SOLR search engine. Default is localhost.
`APREXIS_SOLR_PORT` - specifies the host port of the SOLR search engine. Changing this will allow to run the docker SOLR alongside one running on the host. Default is 8983.

To use the docker services, do not set these in the shell where you run docker. Just set them in the one that you want to run the application.

The environment variable values for docker can be found in the `.env` file in the top-level folder of the docker project.
