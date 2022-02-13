# BURP - BackUp and Restore Program - Docker Images

These are my docker images for
[BURP - BackUp and Restore Program](https://burp.grke.org/), made for my
personal use and shared as-is in the hope it can be useful to someone, with
no warranty of any kind.

Please be sure to test your backups before you need them.

These images have been prepared to allow all configuration to be set as
environment variables, dynamically building the respective configuration files
on container startup (entrypoint). If you don't like this approach, in theses
the conf files could be directly overwritten through docker config or docker
volumes, but that's untested.

## Quick start

`docker-compose.example` is a sample compose file with the full stack: server,
"localhost" client and UI (web interface). It'll configure a single `localhost`
client and backup the host's `/home` using burp defaults for scheduling and
retention.

For using it with the minimal needed customization:

1. Create passwords for the stack's default clients ("localhost" and "burpui"), eg:
  ```shell
  openssl rand -base64 -out secrets/localhost 12
  openssl rand -base64 -out secrets/burpui 12
  sudo chown root. secrets/*
  sudo chmod 600 secrets/*
  ```
2. Copy the `docker-compose.server` to `docker-compose.yml` and adapt as needed:
  * `TZ`: Set your timezone
  * `server_directory`: Set to the directory where the backups will be stored.
    Adjust the volume accordingly.

3. Basic testing
  ```shell
  # Get a shell on client's container
  docker-compose exec burp-client /bin/bash

  # Create a test file
  echo '123456' > /mnt/home/burp-test-file

  # Run a forced backup
  burp -a b

  # Restore test file
  burp -a r -r /mnt/home/burp-test-file -d /tmp

  # Check restored file
  cat /tmp/mnt/home/burp-test-file

  # Cleanup
  rm -rf /tmp/mnt /mnt/home/burp-test-file
  burp -a delete -b 1
  ```

## Configuration

Any configuration parameter accepted by burp can be passed as environment
variables and will be set in the respective conf files at container start.
These env vars must follow the expected syntax:

`<configuration_file>_<parameter_name>[_sequence]`

* `configuration file`: On which file this parameter should be set. One of:
  * `server` : server configuration file (`/etc/burp/burp-server.conf`)
  * `client`: client configuration file (`/etc/burp/burp.conf`)
  * `clientconf_[n]`: client configuration on server. `n` must be an integer
    starting at 0 and will be used to identify to which client each parameters
    belong. `clientconf_[n]_name` must be set to the client name and will be
    used as base for the configuration file name on `/etc/burp/clientconfdir`.
* `parameter_name`: Any configuration parameter accepted by burp
* `sequence`: integer sequence starting at 0 for parameters which can appear
  more than once, such as `keep`, `timer_arg`, `include`, etc.

For more details about burp configuration and the available parameters
please check [burp's documentation](https://burp.grke.org/docs/manpage.html).

## Burp UI

Burp UI is a web client which can be used to see a lot of useful stuff easily,
such as available backups, size, backup reports, etc. On the default
configuration it can be accessed on the docker host through port 5000 and
default credentials (admin:admin).

Access with these default credentials can be very unsafe, so make sure it's
adequate to your environment or reconfigure/disable it.

## Adding new clients

1. Install the client on target system, either by using burp-client image or
   some other distribution;

2. Configure the client to connecto to burp-server and set a password

3. Create a file whose name must be the client's name and content the password
   on `./secrets`

4. Map the file created as a secret on the `docker-compose.yaml` file, both
  on the server configuration and on `secrets` top level directive
  (use `localhost` as a base if needed)

5. Add the desired configuration to the server through `clientconf_<n>` env
   vars (n should be the last client's sequence + 1)

## Other tips and tricks

### Backup on removable disk

For backing up to a removable USB disk while avoiding unwanted backups to the
mount point in case it  isn't connected, making a symbolic link to
the mount point (governed by udisk and therefore not available when
the disk isn't connected) and using that link on `server_directory` has
worked well for me.
