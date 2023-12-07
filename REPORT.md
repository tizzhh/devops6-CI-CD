## Part 1. Setting up the gitlab-runner
- Download and install gitlab-runner on the virtual machine
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt-get install gitlab-runner
```

-Run gitlab-runner and register it for use in the current project (DO6_CICD)
```
sudo gitlab-runner register
```