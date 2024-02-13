# Multi-container demo application

This is an application consisting of several components, to use as the basis of a walkthrough showing how to deploy a multi-container application to the cloud platform.

The components are:

* An API server
* A Postgres database
* A worker process which periodically updates the database
* A Ruby on Rails application which serves content from the database, and also data returned by the API

Each of these components runs in its own container. The Ruby on Rails application reads a record from the database and displays its contents, along with an image supplied via the content API. The worker process periodically updates the database record, and the content API responds to requests (with the URL of a random cat image).

![Architecture Diagram](https://raw.githubusercontent.com/ministryofjustice/cloud-platform-multi-container-demo-app/main/docs/architecture-diagram.png)

Deploying this application to the [MoJ cloud platform][cloudplatform] demonstrates the following deployment requirements:

* Deploying multiple, inter-dependent containers
* Setting up an RDS instance
* Adding deployment secrets (the RDS database credentials)
* Running database migrations
* Putting HTTP basic authentication in front of development apps. on *.service.justice.gov.uk domains

For the HTTP basic authentication, the default user is 'myuser' with password 'password123'.

See the tutorial on [adding basic authentication] for details of how to change this.

## Running the application locally

The .env file holds all the environment varaibles injected into the containers. The only thing to amend is
the password place holder (\<ADD-PASSWORD-HERE\>) with a unique password. 

To run the application locally, you will need [Docker][docker]. After cloning the application from github, run:

      docker-compose up

This will fetch and build all the docker containers which run the different components of the application, i.e. the `rails-app`, `content-api`, `db`, and the `worker`.

See the `docker-compose.yml` file for the details on how this works. More information about `docker-compose` is available [here][docker-compose]

For the local instance of the application, we are running Postgres in an ephemeral docker container. When deployed to the [cloud platform][cloudplatform], we will use an [Amazon RDS][rds] instance.

After the application is started, visit `http://localhost:3000` in your browser, and you should see something similar to this:

![Screenshot](https://raw.githubusercontent.com/ministryofjustice/cloud-platform-multi-container-demo-app/main/docs/screenshot.png)

If you refresh the page, you should see a different cat picture (the URL of which the rails-app fetches from the content-api component).

Every ten seconds, the displayed message should change (you will need to refresh the browser to see the change), when the worker updates the information in the database.

[cloudplatform]: https://github.com/ministryofjustice/cloud-platform
[docker]: https://docker.io
[docker-compose]: https://docs.docker.com/compose/
[rds]: https://aws.amazon.com/rds/
[adding basic authentication]: https://user-guide.cloud-platform.service.justice.gov.uk/tasks.html#add-http-basic-authentication
