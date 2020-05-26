# vuls-scripts
Bash scripts made to ease the use of Vuls

* `vuls-client-scan.sh`: Copy this script on the client to be scanned and execute it.
* `vuls-server.sh`: Start the `vuls` scanning server for using the client scan script.
  * (_can be done also with the `vuls-manage.sh` script_)
* `vuls-manage.sh`: Used to run most of the common actions with Vuls
  * Start the scan server
  * Start the terminal interface
  * Start the web interface
  * Show scan history
  * Generate recent scan reports
  * Generate all scan reports
  * Send scan reports
  * Reset Vuls configuration
  * Update all vulnerabilities databases
  
The scripts are based on [vulsctl](https://vuls.io/docs/en/install-with-vulsctl.html).