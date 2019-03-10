# pipe-s3-to-rsync

Bitbucket pipeline pipe to download a zip from S3, unzip it, and deploy it with rsync.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: proyal/pipe-s3-to-rsync:latest
    variables:
      AWS_REGION: "<string>"
      AWS_SECRET_ACCESS_KEY: "<string>"
      AWS_ACCESS_KEY_ID: "<string>"
      S3_BUCKET: "<string>"
      S3_FILENAME: "<string>"
      REMOTE_USERNAME: "<string>"
      REMOTE_ADDRESS: "<string>"
      REMOTE_PATH: "<string>"
```

## Variables

| Variable                  | Usage                                                       |
| ---------------------     | ----------------------------------------------------------- |
| AWS_REGION (*)            | AWS region. |
| AWS_SECRET_ACCESS_KEY (*) | AWS secret access key. |
| AWS_ACCESS_KEY_ID (*)     | AWS access key id. |
| S3_BUCKET (*)             | S3 bucket name. |
| S3_FILENAME (*)           | S3 download filename, including path. Example: `${BITBUCKET_REPO_SLUG}_${BITBUCKET_COMMIT}.zip`. |
| REMOTE_USERNAME (*)       | Username for remote machine (SSH/rsync). |
| REMOTE_ADDRESS (*)        | Address for remote machine (SSH/rsync). |
| REMOTE_PATH (*)           | Target path on the remote machine (rsync). Could be absolute or relative to home directory. |
| UNZIP_PATH                | Path to unzip downloaded file to. Default: `.dist` |
| RUN_DEPENDENCIES_COMMAND  | If false, will not run the dependency command. Default: `true` |
| DEPENDENCIES_COMMAND      | Command to install dependencies on the remote machine. Will run from the home directory. Default: `npm ci --production` |
| RESTART_COMMAND_TYPE      | If set to `staging` or `production` will set RESTART_COMMAND to some preset commands. These will probably not be useful for most environments. Default: `none` |
| RESTART_COMMAND           | Command to restart server on remote machine. Will run from the home directory. Default: Empty |
| S3_FILENAME_REGEX         | Regex string to validate S3_FILENAME. Default: `^[a-zA-Z0-9_/-]+\.zip$` |

_(*) = required variable._
