# Alpine Inc 🗻 COSC2759 Assignment 2

Created by **Justin Naismith** | s3605206

## Analysis of the problem

> Alpine Inc's current deployment strategy is known as **'ClickOps'**. This is an inefficient and inacccurate way to build the infrastructure their products exist on.
>
> It involves a developer _clicking_ through the often clunky user interface of cloud providers like Amazon Web Services (AWS). This can lead to numerous issues.

**Key issues include:**

### 1. Inefficient

Traversing through the UI of AWS is time-consuming, due to:

- Point and click. Finding where to click and moving your cursor will always be slow
- Large number of services available, often with significant UI differences
- Many pages of service configuration to create a single service
- Drift between documentation screenshots and current versions

All of these factors consume large amounts of developer time when setting up infrastructure.

### 2. Error Prone

Everyone makes mistakes, so getting a developer to setup even a small amount of infrastructure through ClickOps will result in errors that can be hard to troubleshoot and potentially very costly.
One recursive lambda invocation and the next AWS bill is not pretty.

This also poses an issue in a disaster recovery situation. If our infrastructure goes down, how can we accurately rebuild it? Even if we do manage to do so, how long did it take?

### 3. Lack of History

Infrastructure changes to a cloud console can be tracked, but trawling through logs is not as easy as looking at a Git diff. There is also no explanation of _why_ a change was made to the infrastructure, making it difficult to know why a certain service exists, or why it is configured that way. A developer may not want to adjust the settings of an existing service in fear they will bring down production.

## Solution

We will be making use of **Infrastructure as Code (IaC)** to solve the above issues.

Infrastructure as Code allows us to provision cloud resources by writing code. Writing IaC allows us to create, update and delete our network, servers, instances and more, all without having to open the clunky UI of our cloud provider. We will have the ability build up and tear down our entire stack in the span of minutes, as opposed to what would normally be many hours with ClickOps.

Just like the rest of our code, it can be stored in our source control, GitHub. This provides us with an accurate and easy to read history of changes made to our infrastructure. They will also require Pull Requests to enter our repo and pipelines, ensuring that changes are well explained and reviewed by other developers.

AWS has their own IaC platform, CloudFormation, however we have chosen to use HashiCorp's Terraform due to its flexibility between cloud providers, allowing us to migrate to another provider in the future without having to relearn their in-house syntax.

- [ ] Screenshot of application in AWS, include browser URL

## Architecture

Our architecture is built exclusively on AWS.

> <img src="./documentation/web_service.png"/>
>
> Created with [Diagrams as Code](https://diagrams.mingrammer.com/)

Includes:

- [x] VPC
  - The Virtual Private Cloud is deployed into CIDR block `10.0.0.0/16`. This is where we launch our other resources into.
- [x] Availability Zones
  - We are operating within three Availability Zones:
    - `us-east-1a`
    - `us-east-1b`
    - `us-east-1c`
  - These three data centers allow us to spread out the load from our inbound traffic, with load balancers in all three. We deploy our EC2 Instances to `us-east-1a` but are ready to quickly replicate to the other two if required.
- [x] Subnets
  - We have nine Subnets, three in each Availability Zone. Our public, private and data subnets are:
    - `public_az1`, `public_az2`, `public_az3`
    - `private_az1`, `private_az2`, `private_az3`
    - `data_az1`, `data_az2`, `data_az3`
  - These are using different CIDR blocks, TODO explain more about subnets
- [x] Internet Gateway
  - The Internet Gateway allows our VPC to send and receieve traffic from the internet
  - We also use Route Tables to control network traffic and direct it to the IGW
  - [ ] Route Table
- [x] EC2 Instances
  - EC2s are virtual environments that we deploy our applications to.
  - We have:
    - Web application instance
    - Database instance
  - Both instances are running on the latest Amazon Linux AMI
- [ ] Security groups
  - Security groups act as virtual firewalls to control inbound and outbound traffic.
  - We have security groups for our
    - Load balancers
    - Web application instance
    - Database instance
- [ ] Ports
- [ ] port numbers on lines with traffic

We also have an S3 Bucket and DynamoDB table for our Terraform state file, allowing multiple developers to work on the infrastructure at the same time without conflicts.

## Deployment Steps

### Prerequisites

To run the application locally, you must first install the following packages in your linux environment:

**Make**

```
sudo apt install make
```

**[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)**

```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

**[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)**

```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

TODO turn into a make command?

### Initial Setup

For first time setup, you will have to:

1. Get your AWS access key and token from your environment
1. Add AWS keys to `~/.aws/credentials`
1. Run `make ssh-keygen` to create your EC2 keys
1. Run `make bootstrap` to create a Terraform remote state
1. Add the output details into `backend "s3"` inside `infra/main.tf`
1. Run `make infra-init` to initialise your Terraform state

### Run

To build your infrastructure and deploy your app, run `make all-up`

### Teardown

To destroy all your provisioned resources and take the app offline, run `make infra-down`

## Limitations

### Database

For our database, we are using **MongoDB**. We are deploying this to a single EC2 instance.

The main issues with deploying to a single instance are:

1. Data loss in event of disaster

   > We want to ensure we are redundant by replicating our database across instances in different availability zones. We have provisioned our subnets into the three availability zones, `us-east-1a`, `us-east-1b`, `us-east-1c`, so we should make use of these and deploy replicas to them.

1. Poor performance in high-load situations

   > If we encounter a large amount of traffic, our database will perform poorly due to having a single `t2.micro` instance. We can resolve this by upgrading the tier we are using, and/or scaling out our database to other instances. We can also use auto-scaling to scale up our instances when encountering unusually heavy traffic.

Alternative options to running our database in EC2 instances are:

1. DocumentDB

   > Migrate database to DocumentDB, which uses the same APIs as MongoDB. Details on how to migrate can be found [here.](https://docs.aws.amazon.com/documentdb/latest/developerguide/docdb-migration.html)

1. TODO second alternative

   > TODO

### Other

We encountered some other limitations with the new infrastructure setup.

1. AWS Secret Expiry

   > We are storing our AWS secrets in GitHub Secrets, ensuring that they are not being commited to our repository. However, due to the limit on our AWS Console, they expire every 4 hours. <p>This means we have to manually update our secrets. This would not be an issue with a normal AWS environment.<p>To make this easier, we created a Shell script that updates the secrets automatically when run. Note - make sure your `~/.aws/credentials` file has your latest secrets in it. Run it with `make update-credentials`

1. Key Generation

   > Our GitHub Actions pipeline generates a new key-pair for our EC2s every time it runs. The makes Terraform destroy and recreate the `rmit-assignment-2-key` everytime it applies.

1. Diagrams as Code

   > We attempted to use Diagrams as Code to generate AWS diagrams from our Terraform state. With a bit of transformation some progress was made, however the limitations of Diagrams (not possible to link two lists together) meant we went back to a manual diagram.

1. Private Subnets

   > The subnets that we deploy our EC2 instances to are `private_az1` and `data_az1`. These do not output IP addresses as they are not public subnets. For the scope of this assignment, these subnets have been mapped public IP addresses, as instructed in Canvas Discussions.

1. Ansible

   > We had issues getting Ansible working as intended. The `run-ansible.sh` script creates an inventory file with the hosts for `web` and `db` instances, using the Terraform output. Then the Playbook runs, which applys the common template to both instances, before trying to setup the Node app on `web` and MongoDB on `db`.
   >
   > This fails due to error `TASK [web : Run application] fatal: [web]: FAILED! => {"changed": false, "msg": "Could not find the requested service notes.service: host"}`
   >
   > Many hours were spent attempting to get this working with little progress, despite following all the instructions in lab documents.
