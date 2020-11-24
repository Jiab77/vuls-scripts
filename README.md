# vuls-scripts

Bash scripts made to ease the use of [Vuls](https://vuls.io/)

* `vuls-client-scan.sh`: Copy this script on the client to be scanned and run it.
* `vuls-server.sh`: Start the `vuls` scanning server for using the client scan script.
  * (_can be done also with the `vuls-manage.sh` script_)
* `vuls-manage.sh`: Used to run most of the common actions with [Vuls](https://github.com/future-architect/vuls)
  * Start the scan server
  * Start the terminal interface
  * Start the web interface
  * Scan local host
  * Show scan history
  * Generate recent scan reports
  * Generate all scan reports
  * Send scan reports
  * Create / Reset Vuls configuration
  * Update all vulnerabilities databases

The scripts are based on [vulsctl](https://vuls.io/docs/en/install-with-vulsctl.html).

## Usage

You can use the scripts in [Docker](https://docs.docker.com/engine/) based environment with or without the [Rootless](https://docs.docker.com/engine/security/rootless/) mode or natively.

> Please, upload the scripts in the [testing](testing/) folder to your local installation before running the `vuls-*` scripts.
>
> These scripts are not added yet to the [vulsctl](https://github.com/vulsio/vulsctl) project.

### Docker

Script configuration:

```bash
VULSCTL_DIR="$HOME/vulsctl"
DOCKER_DIR="$VULSCTL_DIR/docker"
RESULTS_DIR="$DOCKER_DIR/results"
```

Files to add / update:

* [docker/config-test.sh](testing/docker/config-test.sh) - See pull request [#22](https://github.com/vulsio/vulsctl/pull/22)
* [docker/history.sh](testing/docker/history.sh) - See pull request [#22](https://github.com/vulsio/vulsctl/pull/22)
* [docker/oval.sh](testing/docker/oval.sh) - See pull request [#20](https://github.com/vulsio/vulsctl/pull/20)
* [docker/report.sh](testing/docker/report.sh) - See pull request [#22](https://github.com/vulsio/vulsctl/pull/22)
* [docker/server.sh](testing/docker/server.sh) - See pull request [#19](https://github.com/vulsio/vulsctl/pull/19)

### Native

Script configuration:

```bash
VULSCTL_DIR="$HOME/vulsctl"
VULSREPO_DIR="$HOME/vulsrepo"
INSTALL_DIR="$VULSCTL_DIR/install-host"
RESULTS_DIR="$INSTALL_DIR/results"
```

Files to add / update:

* [install-host/install.sh](testing/install-host/install.sh) - See pull request [#17](https://github.com/vulsio/vulsctl/pull/17)
* [install-host/oval.sh](testing/install-host/oval.sh) - See pull request [#20](https://github.com/vulsio/vulsctl/pull/20)
* [install-host/upgrade.sh](testing/install-host/upgrade.sh) - See pull request [#17](https://github.com/vulsio/vulsctl/pull/17)

## Credits

* [vuls](https://github.com/vulsdoc/vuls) / [vulsctl](https://github.com/vulsio/vulsctl) - Made by [@kotakambe](https://github.com/kotakanbe)
* [vulsrepo](https://github.com/ishiDACo/vulsrepo) - Made by [@ishiDACo](https://github.com/ishiDACo)
* [vuls-scripts](https://github.com/Jiab77/vuls-scripts) - Made by [@Jiab77](https://github.com/Jiab77)
