#!/bin/bash
#******************************************************************************
#    AWS VPC Creation Shell Script
#******************************************************************************
#
# SYNOPSIS
#    Automates the creation of a custom IPv4 VPC, having both a public and a
#    private subnet, and a Internet gateway.
#
# DESCRIPTION
#    This shell script leverages the AWS Command Line Interface (AWS CLI) to
#    automatically create a custom VPC.  The script assumes the AWS CLI is
#    installed and configured with the necessary security credentials.
#
#==============================================================================
#
# NOTES
#
#==============================================================================
#   MODIFY THE SETTINGS BELOW
#==============================================================================
#
AWS_REGION="ap-southeast-1"
VPC_NAME="bp_pro_9511"
VPC_CIDR="172.16.109.0/25"
Environment_TAG="Production"
SUBNET_PUBLIC1_CIDR="172.16.109.0/27"
SUBNET_PUBLIC1_AZ="ap-southeast-1a"
SUBNET_PUBLIC1_NAME="BP_Prod_PUB_1"
SUBNET_PUBLIC2_CIDR="172.16.109.32/27"
SUBNET_PUBLIC2_AZ="ap-southeast-1b"
SUBNET_PUBLIC2_NAME="BP_Prod_PUB_2"
SUBNET_PRIVATE1_CIDR="172.16.109.64/27"
SUBNET_PRIVATE1_AZ="ap-southeast-1a"
SUBNET_PRIVATE1_NAME="BP_Prod_PRV_1"
SUBNET_PRIVATE2_CIDR="172.16.109.96/27"
SUBNET_PRIVATE2_AZ="ap-southeast-1b"
SUBNET_PRIVATE2_NAME="BP_Prod_PRV_2"
securityGroupName="9511_SG_PROD_WEB_SG"
remoteAccessPort="22"
remoteAccessRule1="MX HQ"
remoteAccessPortCidr1="118.140.253.22/32"
remoteAccessRule2="DataCenter"
remoteAccessPortCidr2="165.84.173.100/32"
remoteAccessRule3="MX RSA Server 1"
remoteAccessPortCidr3="10.10.23.71/32"
remoteAccessRule4="MX RSA Server 2"
remoteAccessPortCidr4="10.10.23.72/32"
remoteAccessRule5="JOS Cloud MS"
remoteAccessPortCidr5="203.189.166.1/32"
remoteAccessRule6="MX Infra Team HQ - Private"
remoteAccessPortCidr6="10.20.104.0/24"
remoteAccessRule7="MX Infra Team HQ - Public"
remoteAccessPortCidr7="165.84.173.100/32"
remoteAccessRule8="Solarwind Poller Server 1"
remoteAccessPortCidr8="10.10.23.160/32"
remoteAccessRule9="Solarwind Poller Server 2"
remoteAccessPortCidr9="10.10.23.162/32"
CHECK_FREQUENCY=5
#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
echo "Creating VPC in preferred region..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."

# Add Name tag to VPC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Environment,Value=$Environment_TAG \
  --tags Key=Name,Value=$VPC_NAME \
  --region $AWS_REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."

#60 Create Public1 Subnet
echo "Creating Public Subnet..."
SUBNET_PUBLIC1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC1_CIDR \
  --availability-zone $SUBNET_PUBLIC1_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC1_ID' CREATED in '$SUBNET_PUBLIC1_AZ'" \
  "Availability Zone."

# Add Name tag to Public1 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PUBLIC1_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC1_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC1_ID' NAMED as" \
  "'$SUBNET_PUBLIC1_NAME'."

echo "Creating Public2 Subnet..."
SUBNET_PUBLIC2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC2_CIDR \
  --availability-zone $SUBNET_PUBLIC2_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC2_ID' CREATED in '$SUBNET_PUBLIC2_AZ'" \
  "Availability Zone."

# Add Name tag to Public2 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PUBLIC2_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC2_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC2_ID' NAMED as" \
  "'$SUBNET_PUBLIC2_NAME'."

# Create Private1 Subnet
echo "Creating Private1 Subnet..."
SUBNET_PRIVATE1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE1_CIDR \
  --availability-zone $SUBNET_PRIVATE1_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE1_ID' CREATED in '$SUBNET_PRIVATE1_AZ'" \
  "Availability Zone."

# Add Name tag to Private1 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE1_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE1_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE1_ID' NAMED as '$SUBNET_PRIVATE1_NAME'."

# Create Private2 Subnet
echo "Creating Private2 Subnet..."
SUBNET_PRIVATE2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE2_CIDR \
  --availability-zone $SUBNET_PRIVATE2_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE2_ID' CREATED in '$SUBNET_PRIVATE2_AZ'" \
  "Availability Zone."

# Add Name tag to Private2 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE2_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE2_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE2_ID' NAMED as '$SUBNET_PRIVATE2_NAME'."

# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

## Add a tag to the Internet-Gateway
aws ec2 create-tags \
--resources $IGW_ID \
--tags "Key=Name,Value=$VPC_NAME-IGW"

DEFAULT_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].{RouteTableId:RouteTableId}" --output text)
## Add a tag to Route Table
aws ec2 create-tags --resources $DEFAULT_ROUTE_TABLE_ID --tags "Key=Name,Value=DEFAULT-$VPC_NAME-RT"


# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."

## Add a tag to Route Table
aws ec2 create-tags \
--resources $ROUTE_TABLE_ID \
--tags "Key=Name,Value=$VPC_NAME-Public-RT"

# Create route to Internet Gateway
RESULT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public1 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC1_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC1_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Associate Public2 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC2_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC2_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Use Default Route Table for Private Subnet
#Associate Private1 Subnet with Route Table
#RESULT=$(aws ec2 associate-route-table  \
  # --subnet-id $SUBNET_PRIVATE1_ID \
  # --route-table-id $ROUTE_TABLE_ID \
  # --region $AWS_REGION)
# echo "  Private Subnet ID '$SUBNET_PRIVATE1_ID' ASSOCIATED with Route Table ID" \
  # "'$ROUTE_TABLE_ID'."

# Associate Private2 Subnet with Route Table
# RESULT=$(aws ec2 associate-route-table  \
  # --subnet-id $SUBNET_PRIVATE2_ID \
  # --route-table-id $ROUTE_TABLE_ID \
  # --region $AWS_REGION)
# echo "  Private Subnet ID '$SUBNET_PRIVATE2_ID' ASSOCIATED with Route Table ID" \
  # "'$ROUTE_TABLE_ID'."

# Enable Auto-assign Public IP on Public1 Subnet
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC1_ID \
  --map-public-ip-on-launch \
  --region $AWS_REGION
echo "  'Auto-assign Public IP' ENABLED on Public1 Subnet ID" \
  "'$SUBNET_PUBLIC1_ID'."

# Enable Auto-assign Public IP on Public2 Subnet
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC2_ID \
  --map-public-ip-on-launch \
  --region $AWS_REGION
echo "  'Auto-assign Public IP' ENABLED on Public2 Subnet ID" \
  "'$SUBNET_PUBLIC2_ID'."

#create security group
SG_ID=$(aws ec2 create-security-group \
 --group-name "$securityGroupName" \
 --description "$securityGroupName" \
 --vpc-id "$VPC_ID")
# --query "SecurityGroups[?GroupName == '$securityGroupName'].GroupId" \
# --output text)
echo " Security Group ID '$SG_ID' CREATED."

## Get security group ID's
DEFAULT_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
 --filters "Name=vpc-id,Values=$VPC_ID" \
 --query 'SecurityGroups[?GroupName == `default`].GroupId' \
 --output text) 
CUSTOM_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
 --filters "Name=vpc-id,Values=$VPC_ID" \
 --query "SecurityGroups[?GroupName == '$securityGroupName'].GroupId" \
 --output text)
echo " New CUSTOM Security Group ID is '$CUSTOM_SECURITY_GROUP_ID' queried."
echo " DEFAULT Security Group of '$securityGroupName' ID is '$DEFAULT_SECURITY_GROUP_ID' queried."

## Add a tags to security groups
aws ec2 create-tags \
 --resources "$SG_ID" \
 --tags "Key=Name,Value='$securityGroupName'" 
aws ec2 create-tags \
 --resources "$DEFAULT_SECURITY_GROUP_ID" \
 --tags "Key=Name,Value='default-$VPC_NAME-Security-Group'"

#enable remoteAccessRule1
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=$remoteAccessPort,ToPort=$remoteAccessPort,IpRanges="[{CidrIp=$remoteAccessPortCidr1,Description='Allow $remoteAccessRule1 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable remoteAccessRule2
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=$remoteAccessPort,ToPort=$remoteAccessPort,IpRanges="[{CidrIp=$remoteAccessPortCidr2,Description='Allow $remoteAccessRule2 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable remoteAccessRule3
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=$remoteAccessPort,ToPort=$remoteAccessPort,IpRanges="[{CidrIp=$remoteAccessPortCidr3,Description='Allow $remoteAccessRule3 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable remoteAccessRule4
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=$remoteAccessPort,ToPort=$remoteAccessPort,IpRanges="[{CidrIp=$remoteAccessPortCidr4,Description='Allow $remoteAccessRule4 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable remoteAccessRule5
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=$remoteAccessPort,ToPort=$remoteAccessPort,IpRanges="[{CidrIp=$remoteAccessPortCidr5,Description='Allow $remoteAccessRule5 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable icmpRule6
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges="[{CidrIp=$remoteAccessPortCidr6,Description='Allow $remoteAccessRule6 ICMP'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable icmpRule7
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=icmp,FromPort=-1,ToPort=-1,IpRanges="[{CidrIp=$remoteAccessPortCidr7,Description='Allow $remoteAccessRule7 ICMP'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable icmpRule8
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=65535,IpRanges="[{CidrIp=$remoteAccessPortCidr8,Description='Allow $remoteAccessRule8 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

#enable icmpRule9
AllowPort_Result=$(aws ec2 authorize-security-group-ingress \
 --group-id "$SG_ID" \
 --ip-permissions IpProtocol=tcp,FromPort=0,ToPort=65535,IpRanges="[{CidrIp=$remoteAccessPortCidr9,Description='Allow $remoteAccessRule9 port $remoteAccessPort'}]")
echo " Allow TCP Port '$AllowPort_Result' CREATED."

echo "COMPLETED, please add Load balancer access rules to Security Group after EC2 instances have been attached to Target Group"
