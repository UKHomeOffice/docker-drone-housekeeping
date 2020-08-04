# Drone Housekeeping Docker Image

Runs a script going through the Drone users list and removing the users which haven't logged in for a while.

The behaviour of the sript can be modified with the following parameters:

| Parameter | Description | Required | Default value |
| DRONE_SERVER | URL of the Drone server | Required | n/a |
| DRONE_TOKEN | Administrator Drone token for managing the users | Required | n/a |
| REMOVE_USERS_SKIP_ADMIN | When looking for users to deactivate who have not logged on for a while, skip Admin users | Optional | true |
| REMOVE_USERS_SKIP_INACTIVE | When looking for users to deactivate who have not logged on for a while, skip inactive users | Optional | false |
| REMOVE_USERS_PERIOD | The period users must have not logged on for in order to be deactivated (in days) | Optional | 90 |
| DRY_RUN | Specifies to do a dry run without actually removing users | Optional | false |
| VERBOSITY | How verbose the output should be (0 == warnings, errors; 1 == info; 2 == debug) | Optional | 1 |
