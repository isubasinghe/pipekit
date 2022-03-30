---
title: Starting with Argo Workflows
path: starting-with-argo
description: null
date: null
---
# How to Run the Argo Workflows codebase locally

In this tutorial, you'll learn how to run the Argo Workflows codebase locally, including the API and UI, using the [minikube](https://minikube.sigs.k8s.io/docs/) distribution of Kubernetes. We'll install each dependency step-by-step, with instructions for Windows, macOS, and Ubuntu-Linux. If you're new to developing on Argo Workflows, this is a perfect place to start.

## What is Argo Workflows?

Argo Workflows is an open source workflow engine for orchestration of jobs (workflows) on Kubernetes.
What Argo Workflows allows you to do is to define a set of tasks and its dependencies as a directed acyclic graph (DAG).

To further ground what a workflow is, we can examine a particular instance of a workflow, ETL workloads.
ETL is an extremely common process used for integrating multiple sources of data into one centralised location so that it can be consumed by downstream tasks such as analytics, machine learning, etc.

ETL is quite simple, it follows the three simple steps.
  - Extract - Raw data is extracted from multiple sources
  - Transform - Various preprocessing steps are performed such as cleansing, normalization
  - Load - The new data is loaded into a database for use in downstream tasks

That said, Argo Workflows can do more than just ETL. It's a good fit for general workflows be it CI/CD, Bioinformatics, infrastructure automation, and more.

## How to run Argo Workflows

Let's get started on running Argo Workflows locally. For the Ubuntu steps, we will be working with a fresh Ubuntu 20.04 LTS installation.

Alternatively, if you would like to get Argo Workflows up and running in the cloud, I have provided some [Terraform scripts here](https://github.com/isubasinghe/pipekit) to get it running on AWS.

## Requirements
- Docker
- Minikube
- protoc
- node
- npm
- Yarn
- jq
- Go 1.17

### Installing Docker
The Docker website [provides](https://docs.docker.com/get-docker/) a comprehensive guide into installing docker.
I have provided the steps for macOS, Windows and Ubuntu below, this should still provide help when installing Docker on other distributions.

#### Windows
Installing Docker Desktop on windows is quite simple:

1. Download the Docker Desktop Installed from [Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-windows/).

2. Double click on the `Docker Desktop Installer.exe` file that you just downloaded.

3. When the installation finishes, open up PowerShell and check if your installation was successful by running `docker version`.

#### macOS
Installing Docker Desktop on macOS is just as simple as on windows:

1. Download dmg file from [here](https://docs.docker.com/desktop/mac/install/) depending on your chip, either Intel or Apple silicon.

2. Double click on the dmg to open the installer, from here you simply need to drag and drop the Docker icon into the Applications folder.

3. Search for Docker in launchpad and click to launch Docker.

#### Ubuntu

##### Uninstall old versions
If you already have an old version of docker, you may first uninstall that. This can be fairly easily achieved through running:
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```
Note that this will not remove images, containers, volumes and networks which are installed at `/var/lib/docker`. If you would like to
remove these first, you may run:
```bash
docker system prune --all
```
##### Install using the repository
First let's install the utilities we need to add the docker repository by running the two commands below:
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
```
Now we can add Docker's official GPG key by:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

And now we can setup the **stable** repository:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
After this process, the latest docker binaries should be available for download following an update, you can use the below commands to install docker:
```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Verify docker has been installed correctly by running `docker ps` you should see output like this:
<img src="https://github.com/isubasinghe/pipekit/raw/main/docker.png" alt="docker command line output of CONTAINER ID IMAGE COMMAND CREATED STATUS  PORTS NAMES"/>

In the case you get a permission error, you need to add setup docker to run without root privileges.

To do this, you must follow the steps below:

  1. Create the docker group:

  ```bash
  sudo groupadd docker
  ```

  2. Add your user to the `docker` group:

  ```bash
  sudo usermod -aG docker $USER
  ```

  3. Run the following command to activate the changes to groups:

  ```bash
  newgrp docker
  ```

### Installing Minikube

As with Docker, the k8s website [provides](https://minikube.sigs.k8s.io/docs/start/) a more comprehensive guide to installing minikube on various architectures, so we will cover the installation of a minikube on x86-64 only.

#### Windows
To install the latest minikube stable:
Download the latest release by running the following PowerShell command:

```powershell
New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
```
After this we also need to add `minikube` to our PATH, this can be achieved through running:
```powershell
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube'){ `
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine) `
}
```

#### macOS
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

#### Ubuntu
The process is quite straightforward, simply run the command below:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Installing protoc
Your distribution may have protobuf already installed, but I would not recommend using this installation. When I first attempted running
Argo Workflows on my Fedora installation, protobuf on the system was missing the entirety of the include folder. You may find the installation instructions [here](http://google.github.io/proto-lens/installing-protoc.html), but it is fairly simple.

#### Windows
Unfortunately the protobuf website does not provide instructions for installing protobuf on Windows but it is farily simple because binaries are provided on the github [repository](https://github.com/protocolbuffers/protobuf/releases/).
Simply download these and extract them to a directory (such as `C:\Program Files\protobuf`) and add the `bin` and `include` directories to the PATH variable.

#### macOS
The steps are given below for macOS but note that this is not for the latest apple silicon but x86-64. Binaries have not
been released for apple silicon at the time of writing this. Here are the steps:
```bash
PROTOC_ZIP=protoc-3.14.0-osx-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP
```

#### Ubuntu
The steps are given below for Ubuntu:
First install `zip` and `unzip`:
```bash
sudo apt-get install zip
```
Now we may install protobuf through:
```bash
PROTOC_ZIP=protoc-3.14.0-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP
```
Try running `protoc` now, if you get a permission error, simply run `sudo chmod +x $(which protoc)`.
You can of course view the permissions by navigating to `/usr/local` and running `ls -lah`.

### Installing Yarn, Npm and Node

#### Windows
Through the nodejs [website](https://nodejs.org/en/download/) you may download the latest installer, here is the link for [node v16.13.1](https://nodejs.org/dist/v16.13.1/node-v16.13.1-x86.msi).

1. Once you have downloaded the installer, simply double click on it.

2. The system may ask you if you want to run the software, you should click on run. This should launch the Setup Wizard, make sure the installer adds the binary folder to the PATH variable.

3. Verify the installation by running `node` on a command prompt.


#### macOS & Ubuntu
I would recommend installing `npm` and `node` via [nvm](https://github.com/nvm-sh/nvm).
The install process is quite simply, just run:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```   
You should of course run `source ~/.bashrc` or `source /.zshrc` after this and verify the installation by running `nvm`.

Following this, you can install node by `nvm install node`.
To install yarn, you may simply run `npm install -g yarn` after this step.

### Installing jq
`jq` is the one item in this list that I would recommend installing through your system itself (apt/dnf/yum), you may get a slightly outdated version, but it shouldn't matter as much as the other tools.

#### Windows
The steps on Windows are a bit more complex.
1. Download a windows executable from [here](https://github.com/stedolan/jq/releases).
2. Rename your exe which at the time of writing had this format `jq-win(32|64).exe` to just `jq.exe`.
3. Then move the executable to `C:\Program Files\jq\`, the executable should now be located at `C:\Program Files\jq\jq.exe`.
4. Add this folder to the PATH variable.

#### macOS
On macOS simply run:
```bash  
brew install jq
```

#### Ubuntu
On Ubuntu, simply run:
```bash
sudo apt-get install jq
```

### Installing Go

#### Windows
The installer for go provided in the Golang [website](https://go.dev/doc/install) is likely the easiest way to install go on Windows.
This is once again the standard `msi` installer we have encountered previously.

1. Simply download the installer from the [website](https://go.dev/doc/install).

2. Double click on the installer and follow the prompts to install Go

3. Verify your installation by opening up a command prompt and typing `go version`.

#### macOS
Brew typically contains the latest release of golang and we should have an easier installtion method by using `brew`, simply run the commands below to get Go on macOS through brew:
```bash
brew install go
```

#### Ubuntu
As with nearly previous steps, refer to the [official website](https://go.dev/doc/install) for a comprehensive guide but I will now cover how I installed go 1.17.5 on my Ubuntu installation.

1. Download the binaries
  A link for the binaries is provided in the website above but here it is anyway: [https://go.dev/dl/go1.17.5.linux-amd64.tar.gz](https://go.dev/dl/go1.17.5.linux-amd64.tar.gz).
  This can be performed on the command line by running the below command:
  ```bash
  wget https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
  ```
  You should be able to run `ls` to verify that the download was successful.

2. Extract the archive
  This can be done by running the following command:
  ```bash
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz
  ```
3. Add /usr/local/go/bin to the PATH environment variable.
  Open up your ~/.bashrc or ~/.zshrc file and add the /usr/local/go/bin path
  to it. This is quite simply done in bash by adding the following line: `export PATH=$PATH:/usr/local/go/bin`.

4. Verify installation of Go.
  If you are still in the same shell, it is likely that your PATH variable has not been updated. To apply the changes
  without leaving the shell run `source ~/.bashrc` or `source ~/.zshrc` or similar depending on your shell. You should be able
  to verify the existance of Golang by running `go version`.

5. Set the GOPATH.
  First make a directory called `go` in your home directory. This is achieved through:
  ```bash
  mkdir /home/$USER/go
  ```
  If your GOPATH is not set, you need to define it. this is quite simple. Just open up the `~/.bashrc` or `~/.zshrc` file and add
  `export GOPATH=/home/$USER/go`. Verify the that the path was correctly set by running `go env`.

### Other important notes
Please make sure the following is appended to your /etc/hosts file:
```text
127.0.0.1 dex
127.0.0.1 minio
127.0.0.1 postgres
127.0.0.1 mysql
```

## Cloning the Argo Workflows repository
Before we clone Argo Workflows, let's make sure that our GOPATH is set by running `echo $GOPATH`.
Now we need to clone the argo-workflows repo into exactly the correct directory. This is critical to ensure everything works as expected.
This directory is `$GOPATH/src/github.com/argoproj/argo-workflows`, you may need to `mkdir` some folders in order to have this structure, feel free to
do so and then navigate to `$GOPATH/src/github.com/argoproj`.
From here we may clone the project by running:
```bash
git clone git@github.com:argoproj/argo-workflows.git
cd argo-workflows
```

## Starting minikube
In order to start minikube we can run:
```bash
minikube start
```
You may also view the status of minikube by running:
```bash
minikube status
```
Of course, had you installed `kubectl`, you would also be able to view information about the cluster.

## Setting up Docker for minikube
minikube runs in a VM, the Docker images you build locally are not accessible to the Docker deamon in minikube.
You need to build your images on the Docker deamon in minikube. You can do this by pointing the Docker host to minikube.
This can be achieved by:
```bash
eval $(minikube -p minikube docker-env)
```

## Run Argo Workflows locally
Nice work, now we are finally at a stage where we can run the Argo Workflows project.
You may need to install `make` but this is straightforward to install through your systems package manager.

### Run the Argo Workflows API only
To run only the api, you can run the following command:
```bash
make start API=true
```

### Running the Argo Workflows API and UI
To run and use the Argo Workflows UI you may run the following command:
```bash
make start API=true UI=true
```
