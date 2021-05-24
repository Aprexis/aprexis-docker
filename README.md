# Dockerized Aprexis

This project allows a user or developer to run the Aprexis system locally using docker. It requires a working docker installation.

## Varieties

There are two setups for running the Aprexis system:

1. The basic platform, consisting of the Rails application and the Resque system, along with the supporting databases and the SOLR search engine.

2. The complete application, which adds the API and the user interface for the API to the basic platform.

The variety is controlled by the environment variable APREXIS_VARIETY, which can take the values:

- platform
- api (the default)

## Set up

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
