Purpose
---
The purpose of this repository is to build a Custom AWS AMI that is used in AWX by the Server Build Template.  This repository uses the Docker image built by infra-container-imagebuilder that contains both Packer and Ansible.

![Alt text](images/infra-utility-imagefactory.v2.png?raw=true "BitBucket Drone CI Packer Build Of Custom AWS AMI")

How Build Is Run
---
The build of the Custom AWS AMI can be launched by a Drone Cron Job or via a Pull Request (PR) in BitBucket which triggers the Drone build.  The build trigger is configured in the BitBucket infra-utility-imagefactory repository -> Repository settings -> Webhooks setting.  Also, the repository has to be enabled in Drone in the Repositories -> infra-utility-imagefactory -> Settings -> General setting (bottom left is a button labelled Disable or Enable)

How to start Drone
---
On SPLAWSSREDKR01 perform the following from CLI:

1. First determine if Drone or Drone Runner are running

```
docker ps
```

2. If you do not see a container with image of drone/drone and drone/registry-plugin then you should start drone with the following commands:

```
cd /docker/drone
docker-compose pull && docker-compose down --remove-orphans && docker-compose rm && docker-compose up -d
```

How to run Drone CLI commands
---
https://docs.drone.io/cli/configure/

The command line tools interact with the server using REST endpoints. You will need to provide the CLI tools with the server addresses and your personal authorization token. You can find your authorization token in your Drone account settings (click your Avatar in the Drone user interface).

https://drone.sre.compucom.com/account

Example CLI Usage
---
```
$ export DRONE_SERVER=https://drone.sre.compucom.com
$ export DRONE_TOKEN=
$ drone info
```

How to look at Drone logs
---
$ docker container logs <Drone container id>

[Show Drone Logs](https://docs.drone.io/server/logging/)

$ docker logs <container name>

Prerequisite Configuration for Bitbucket to Trigger a Drone Build
---
- .drone.yml file in the Bitbucket repository
- Webhook defined in the Bitbucket repository settings ({{Repository Name}} -> Repository settings -> Webhooks setting)
- Repository enabled in the Drone settings (Repositories -> {{Repository Name}} -> Settings -> General setting (bottom left is a button labelled Disable or Enable)

How to trigger a Drone build of Repository
---
Merge a Pull Request (PR) of the infra-utility-imagefactory repository.  Depending on how the repository's Branch permissions are configured the git merge may require both the developer's and a reviewer's approval.

Monitor Drone build
---
While connected to the CompuCom VPN, go to the Drone console (https://drone.sre.compucom.com/) and select Builds and then click on the desired build.

Required Resources
---
The Docker image created by the infra-container-imagebuilder repository is stored in the 472510080448.dkr.ecr.us-east-1.amazonaws.com AWS Elastic Container Registry (ECR).  ECR is a fully managed Docker container registry.

Get Information from Ansible and/or Packer during AMI Build
---

```
docker ps
```

```
docker exec {container id} find / -name buildfiles
docker exec {container id} ls /drone/src/buildfiles
docker exec {container id} ls /drone/src/buildfiles/linux/antivirus
docker exec {container id} ls -ltr /drone/src/buildfiles/linux/antivirus
```

Shell session in container
---

```
docker exec -it {container id} sh
```