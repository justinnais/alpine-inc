from diagrams import Diagram, Cluster, Edge
from diagrams.generic.blank import Blank
from diagrams.generic.compute import Rack
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, InternetGateway, PublicSubnet, PrivateSubnet, RouteTable, ELB
import json
import os
from pprint import pprint
from operator import itemgetter


## Opening the .tfstate file
with open('infra/terraform.tfstate.backup') as json_file:
    tf_data = json.load(json_file)

resources = tf_data['resources']
resourceMap = {}
## looping over the names
for resource in resources:
  name = str(resource['name'])
  instances = []
  for instance in resource['instances']:
    instances.append(instance['attributes'])

  
  resourceMap[name] = {
    'name': name,
    'type': resource['type'],
    'instances': instances
    
  }

# pprint(resourceMap)

awsResourceMap = {
  'aws_vpc': VPC,
  'aws_internet_gateway': InternetGateway,
  'aws_subnet': PublicSubnet,
  'aws_default_route_table': RouteTable,
  'aws_instance': EC2,
  'aws_security_group': 'TODO',
  'aws_lb_target_group': 'TODO',
  'aws_lb_listener': 'TODO',
  'aws_lb': ELB,
  'aws_key_pair': 'TODO',
}

# Ideally would like to generate each diagram node programmatically but not sure if possible
# for key, value in resourceMap.items():
  # print(awsResourceMap[value['type']])


def getKey(key):
  return resourceMap[key]['name']

def getName(key, index = 0):
  return resourceMap[key]['instances'][index]['tags']['Name']

def getCidrBlock(key, index = 0):
  return resourceMap[key]['instances'][index]['cidr_block']

# pull from the resourceMap later
availabilityZones = ['us-east-1a', 'us-east-1b', 'us-east-1c']

azSubnets = {}
for az in availabilityZones:
  azSubnets[az] = []

# Mapping subnet instances to their parent AZ
for key, value in resourceMap.items():
  if value['type'] == 'aws_subnet':
    for instance in value['instances']:
      azSubnets[instance['availability_zone']].append(instance)

def getIngressEgress(attributes):
  ingress = attributes['ingress']
  egress = attributes['egress']
  return ingress, egress

def getSecurityGroupLabel(key):
  securityGroupAtributes = resourceMap[key]['instances'][0]
  ingress, egress = getIngressEgress(securityGroupAtributes)

  ingress_labels = []
  egress_labels = []
  for rule in ingress:
    ingress_labels.append(rule['description'] + " - " + "Port " + str(rule['from_port']) + " to " + str(rule['to_port']) + "\nCIDR: " + rule['cidr_blocks'][0])
  for rule in egress:
    egress_labels.append(rule['description'] + " - " + "Port " + str(rule['from_port']) + " to " + str(rule['to_port']) + "\nCIDR: " + rule['cidr_blocks'][0])

  # return "Security Group: " + key + "\nIngress:\n" + "\n".join(ingress_labels) + "\nEgress:\n" + "\n".join(egress_labels)
  return "Security Group: " + key


print("\nGenerating Diagram...")
graph_attr = {
    "fontsize": "30",
}

node_attr = {
  # "fontsize": "20",
  
}

sg_attr = {
  "bgcolor": "#FDF7E3",
  
  # "fontsize": "24"

}
with Diagram("Web Service", direction="TB", filename="documentation/web_service", graph_attr=graph_attr, node_attr=node_attr):
  igw = InternetGateway('igw')
  publicSubnets = []
  ec2s = []

  with Cluster("VPC: " + getKey('main') + "\nCIDR: " + getCidrBlock('main'), graph_attr=graph_attr):
    intermediateBlank = Blank("Intermediate")

    with Cluster(getSecurityGroupLabel('load_balancer_sg'), graph_attr=sg_attr):
      loadBalancer = ELB("load_balancer_sg")
    for azKey, azValue in azSubnets.items():
      with Cluster("Availability Zone: " + azKey):
        for i, subnet in enumerate(azValue):
          with Cluster("Subnet: "+ subnet['tags']['Name']+"\nCIDR: "+subnet['cidr_block']):
            if ('public' in subnet['tags']['Name']):
              publicSubnets.append(Blank())
            if (subnet['tags']['Name'] == 'private_az1'):
              with Cluster(getSecurityGroupLabel('web_sg'), graph_attr=sg_attr):
                ec2s.append(EC2("web"))
                # web = EC2("web")
            elif ('private' in subnet['tags']['Name']):
              Blank()
            if (subnet['tags']['Name'] == 'data_az1'):
              with Cluster(getSecurityGroupLabel('db_sg'), graph_attr=sg_attr):
                ec2s.append(EC2("db"))
                # db = EC2("db")
            elif ('data' in subnet['tags']['Name']):
              Blank()


  igw >> Edge(label="in: 80\nout: 0") << loadBalancer >> publicSubnets
  web = ec2s[0]
  db = ec2s[1]
  publicSubnets >> Edge(label="in: 80, 22\nout: 0") << web
  publicSubnets >> Edge(label="in: 27017, 22\nout: 0") << db
  # ec2s >> Edge(color="red", label="Port 0") >> igw
  # publicSubnets >> Edge(color="red", label="Port 0")>>  loadBalancer >> Edge(color="red", label="Port 0")  >> igw
  