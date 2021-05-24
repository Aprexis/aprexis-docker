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

1. Clone the aprexis-docker project
2. cd aprexis-docker
3. Clone the aprexis-platform-5 project
4. Clone the aprexis-api project
5. Clone the aprexis-api-ui project
6. Download the anonymized Aprexis data into the aprexis-data folder (you can leave this zipped)
7. Build the desired variety
8. Build the database
9. Launch the application
10. Shutdown docker when done

The application, API, the UI for API are all set up to automatically load changes (although you will need to refresh the browser to get the UI changes into a running tab). If you are wish to restart, you can generally use just steps 9 and 10.

### Clone the aprexis-docker project

Use the following command to do the clone:


