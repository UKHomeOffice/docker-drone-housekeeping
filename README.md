# Drone Housekeeping Docker Image and Helm Chart

## Docker Image

Runs a script going through the Drone users list and removing the users which haven't logged in for a while in order to manage licences.

The behaviour of the script can be modified with the following parameters:

| Parameter | Description | Required | Default value |
|---|---|---|---|
| DRONE_SERVER | URL of the Drone server | Required | n/a |
| DRONE_TOKEN | Administrator Drone token for managing the users | Required | n/a |
| REMOVE_USERS_SKIP_ADMIN | When looking for users to deactivate who have not logged on for a while, skip Admin users | Optional | true |
| REMOVE_USERS_SKIP_INACTIVE | When looking for users to deactivate who have not logged on for a while, skip inactive users | Optional | false |
| REMOVE_USERS_PERIOD | The period users must have not logged on for in order to be deactivated (in days) | Optional | 90 |
| REMOVE_USERS_SKIP_USERS | List of space-separated users that should not be checked (the id of the user the drone token running the script should be specified) | Optional | "admin" |
| DRY_RUN | Specifies to do a dry run without actually removing users | Optional | false |
| VERBOSITY | How verbose the output should be (0 == warnings, errors; 1 == info; 2 == debug) | Optional | 1 |

The image is published in quay.io's [ukhomeofficedigital/drone-housekeeping](https://quay.io/repository/ukhomeofficedigital/drone-housekeeping?tab=tags) docker repository.

## Helm Chart

### Chart info

The Helm chart for the image above is also published on quay.io, in the [ukhomeofficedigital/helm-drone-housekeeping](https://quay.io/application/ukhomeofficedigital/helm-drone-housekeeping?tab=releases) application repository.

See [helm/values.yaml](helm/values.yaml) for a list of the supported chart parameters.

In particular, if you need to specify different parameters for the container, you can use the `extraEnv` Helm parameter to pass additional environment variables to the container running the job.

### Generating a drone robot token

A token for the robot user doing the housekeeping needs to be generated for the job to be successful. That token needs to have Drone admin privileges as it retrieves user metadata and removes some users.

As a drone admin, create a housekeeper robot:

``` bash
drone user add --admin --machine housekeeper
```

Assign the token above to environment variable `DRONE_ROBOT_TOKEN` and create a secret in the namespace where the housekeeping job is going to run. The name of the secret should be the same as the one of the helm chart release, so replace `$HELM_RELEASE_NAME` below with the name of the release you specify in `helm install` or `helm upgrade`.

``` bash
kubectl create secret generic $HELM_RELEASE_NAME --from-literal DRONE_TOKEN=$DRONE_ROBOT_TOKEN --from-literal DRONE_SERVER=$DRONE_SERVER
```

## Publishing

To publish the Docker image, tag the repo with the image version, prefixed with `docker-`. For example, `docker-1.0.0`.

To publish the Helm chart, tag the repo with the helm chart version, prefixed with `helm-`. For example, `helm-1.0.0`. Please note that the version specified in the tag must match `version` in [helm/Chart.yaml](helm/Chart.yaml) and quay.io expects the version number to follow [semver](https://semver.org/) (in the format `major.minor.patch`).
