
The goal of this project is to get familiar with systemd; creating and enabling a service, checking the status, keeping an eye on the logs, starting and stopping the service, etc.

### Prepare the environment with terraform:
Prerequisites:
 - Clone the repo
 - API token
 - SSH key uploaded and configured on DigitalOcean
-  File *terraform.tfvars* with these variables set: `ssh-key-name`, `home-path`
```sh
 export DO_PAT="dop_v1_ ..." # Export your DigitalOcean API key

# Initialize Terraform and create resources
terraform init
terraform apply -var "do_token=${DO_PAT}"
```
### Connect to the remote server using command that was returned in terraform output in the terminal

### Create and test the `systemd` Service

 1. Copy the script and grant it execute permissions:
    ```sh
    sudo cp dummy.sh /usr/local/bin/dummy.sh && sudo chmod +x /usr/local/bin/dummy.sh
    ```
 2.  Create a new service configuration file:
     ```sh
     cat << EOF | sudo tee /etc/systemd/system/dummy.service > /dev/null
     [Unit]
     Description=Dummy service that writes to the log every 10 seconds
     
     [Service]
     User=root
     Group=root
     WorkingDirectory=/root
     ExecStart=/usr/local/bin/dummy.sh
     Restart=always
     RestartSec=3
     
     [Install]
     WantedBy=multi-user.target
     EOF
     ```
3. Reload the service files to recognize the newly created service:
    ```sh
    sudo systemctl daemon-reload
    ```
4. Test the service by interacting with it and checking its logs:
    ```sh
    # Start and stop the service
    sudo systemctl start dummy
    sudo systemctl stop dummy
    
    # Enable and disable the service
    sudo systemctl enable dummy
    sudo systemctl disable dummy

    # Check the service status
    sudo systemctl status dummy

    # Check the logs
    sudo journalctl -u dummy -f
    ```

Challenge url: https://roadmap.sh/projects/dummy-systemd-service
