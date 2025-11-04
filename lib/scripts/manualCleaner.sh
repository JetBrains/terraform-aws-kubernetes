#!/bin/bash
# Script to delete all AWS resources tagged with ResourceCreatedBy=TerraformModule:terraform-aws-kubernetes
# WARNING: This script is destructive and will permanently delete resources!

set -euo pipefail

TAG_KEY="ResourceCreatedBy"
TAG_VALUE="TerraformModule:terraform-aws-kubernetes"
REGION="${AWS_REGION:-$(aws configure get region)}"

if [ -z "$REGION" ]; then
    echo "Error: AWS region not set. Please set AWS_REGION or configure AWS CLI."
    exit 1
fi

echo "=========================================="
echo "WARNING: This will delete ALL resources"
echo "Tagged with: ${TAG_KEY}=${TAG_VALUE}"
echo "In region: ${REGION}"
echo "=========================================="
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Function to delete resources by tag
delete_resources_by_tag() {
    local resource_type=$1
    local filter_name=$2
    local delete_cmd=$3
    
    echo "Processing ${resource_type}..."
    local resources=$(aws resourcegroupstaggingapi get-resources \
        --region "$REGION" \
        --tag-filters "Key=${TAG_KEY},Values=${TAG_VALUE}" \
        --resource-type-filters "${resource_type}" \
        --query "ResourceTagMappingList[*].ResourceARN" \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$resources" ] && [ "$resources" != "None" ]; then
        for arn in $resources; do
            echo "  Found: $arn"
            # Extract resource ID from ARN
            local resource_id=$(echo "$arn" | awk -F'/' '{print $NF}')
            local resource_id2=$(echo "$arn" | awk -F':' '{print $NF}' | awk -F'/' '{print $NF}')
            
            # Try to delete using the delete command
            if eval "$delete_cmd" 2>&1; then
                echo "  ✓ Deleted: $resource_id"
            else
                echo "  ✗ Failed to delete: $resource_id (may have dependencies)"
            fi
        done
    fi
}

# Delete EKS Addons first (before cluster)
echo "=== Step 1: Deleting EKS Addons ==="
clusters=$(aws eks list-clusters --region "$REGION" --query "clusters[]" --output text 2>/dev/null || echo "")
for cluster in $clusters; do
    addons=$(aws eks list-addons --cluster-name "$cluster" --region "$REGION" --query "addons[]" --output text 2>/dev/null || echo "")
    for addon in $addons; do
        tags=$(aws eks describe-addon --cluster-name "$cluster" --addon-name "$addon" --region "$REGION" --query "addon.tags.${TAG_KEY}" --output text 2>/dev/null || echo "")
        if [ "$tags" = "$TAG_VALUE" ]; then
            echo "  Deleting addon: $addon from cluster: $cluster"
            aws eks delete-addon --cluster-name "$cluster" --addon-name "$addon" --region "$REGION" 2>/dev/null || true
        fi
    done
done

# Wait for addons to be deleted
echo "Waiting for addons to be deleted..."
sleep 30

# Delete EKS Node Groups
echo "=== Step 2: Deleting EKS Node Groups ==="
for cluster in $clusters; do
    nodegroups=$(aws eks list-nodegroups --cluster-name "$cluster" --region "$REGION" --query "nodegroups[]" --output text 2>/dev/null || echo "")
    for nodegroup in $nodegroups; do
        tags=$(aws eks describe-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" --region "$REGION" --query "nodegroup.tags.${TAG_KEY}" --output text 2>/dev/null || echo "")
        if [ "$tags" = "$TAG_VALUE" ]; then
            echo "  Deleting node group: $nodegroup from cluster: $cluster"
            aws eks delete-nodegroup --cluster-name "$cluster" --nodegroup-name "$nodegroup" --region "$REGION" 2>/dev/null || true
        fi
    done
done

# Wait for node groups to be deleted
echo "Waiting for node groups to be deleted..."
sleep 60

# Delete EKS Clusters
echo "=== Step 3: Deleting EKS Clusters ==="
for cluster in $clusters; do
    tags=$(aws eks describe-cluster --name "$cluster" --region "$REGION" --query "cluster.tags.${TAG_KEY}" --output text 2>/dev/null || echo "")
    if [ "$tags" = "$TAG_VALUE" ]; then
        echo "  Deleting cluster: $cluster"
        aws eks delete-cluster --name "$cluster" --region "$REGION" 2>/dev/null || true
    fi
done

# Delete Auto Scaling Groups
echo "=== Step 4: Deleting Auto Scaling Groups ==="
delete_resources_by_tag "autoscaling:autoScalingGroup" "" \
    "aws autoscaling delete-auto-scaling-group --auto-scaling-group-name \$resource_id --force-delete --region $REGION"

# Delete Launch Templates
echo "=== Step 5: Deleting Launch Templates ==="
lt_ids=$(aws ec2 describe-launch-templates --region "$REGION" --query "LaunchTemplates[?Tags[?Key=='${TAG_KEY}' && Value=='${TAG_VALUE}']].LaunchTemplateId" --output text 2>/dev/null || echo "")
for lt_id in $lt_ids; do
    echo "  Deleting launch template: $lt_id"
    aws ec2 delete-launch-template --launch-template-id "$lt_id" --region "$REGION" 2>/dev/null || true
done

# Delete EC2 Instances
echo "=== Step 6: Deleting EC2 Instances ==="
instance_ids=$(aws ec2 describe-instances --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" "Name=instance-state-name,Values=running,pending,stopped,stopping" \
    --query "Reservations[*].Instances[*].InstanceId" --output text 2>/dev/null || echo "")
if [ -n "$instance_ids" ] && [ "$instance_ids" != "None" ]; then
    for instance_id in $instance_ids; do
        echo "  Terminating instance: $instance_id"
        aws ec2 terminate-instances --instance-ids "$instance_id" --region "$REGION" 2>/dev/null || true
    done
fi

# Delete NAT Gateways
echo "=== Step 7: Deleting NAT Gateways ==="
nat_gw_ids=$(aws ec2 describe-nat-gateways --region "$REGION" \
    --filter "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "NatGateways[?State=='available'].NatGatewayId" --output text 2>/dev/null || echo "")
for nat_gw_id in $nat_gw_ids; do
    echo "  Deleting NAT Gateway: $nat_gw_id"
    aws ec2 delete-nat-gateway --nat-gateway-id "$nat_gw_id" --region "$REGION" 2>/dev/null || true
done

# Wait for NAT gateways to be deleted
echo "Waiting for NAT gateways to be deleted..."
sleep 30

# Delete Elastic IPs
echo "=== Step 8: Deleting Elastic IPs ==="
allocation_ids=$(aws ec2 describe-addresses --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "Addresses[].AllocationId" --output text 2>/dev/null || echo "")
for allocation_id in $allocation_ids; do
    echo "  Releasing Elastic IP: $allocation_id"
    aws ec2 release-address --allocation-id "$allocation_id" --region "$REGION" 2>/dev/null || true
done

# Delete VPC Endpoints
echo "=== Step 9: Deleting VPC Endpoints ==="
vpc_endpoint_ids=$(aws ec2 describe-vpc-endpoints --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "VpcEndpoints[].VpcEndpointId" --output text 2>/dev/null || echo "")
for vpce_id in $vpc_endpoint_ids; do
    echo "  Deleting VPC Endpoint: $vpce_id"
    aws ec2 delete-vpc-endpoint --vpc-endpoint-id "$vpce_id" --region "$REGION" 2>/dev/null || true
done

# Delete Internet Gateways (detach first)
echo "=== Step 10: Detaching and Deleting Internet Gateways ==="
igw_ids=$(aws ec2 describe-internet-gateways --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "InternetGateways[].InternetGatewayId" --output text 2>/dev/null || echo "")
for igw_id in $igw_ids; do
    vpc_id=$(aws ec2 describe-internet-gateways --internet-gateway-ids "$igw_id" --region "$REGION" \
        --query "InternetGateways[0].Attachments[0].VpcId" --output text 2>/dev/null || echo "")
    if [ "$vpc_id" != "None" ] && [ -n "$vpc_id" ]; then
        echo "  Detaching Internet Gateway: $igw_id from VPC: $vpc_id"
        aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null || true
    fi
    echo "  Deleting Internet Gateway: $igw_id"
    aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION" 2>/dev/null || true
done

# Delete Subnets (after detaching route table associations)
echo "=== Step 11: Deleting Subnets ==="
subnet_ids=$(aws ec2 describe-subnets --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "Subnets[].SubnetId" --output text 2>/dev/null || echo "")
for subnet_id in $subnet_ids; do
    echo "  Deleting subnet: $subnet_id"
    aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION" 2>/dev/null || true
done

# Delete Route Tables (except main)
echo "=== Step 12: Deleting Route Tables ==="
rt_ids=$(aws ec2 describe-route-tables --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "RouteTables[].RouteTableId" --output text 2>/dev/null || echo "")
for rt_id in $rt_ids; do
    echo "  Deleting route table: $rt_id"
    aws ec2 delete-route-table --route-table-id "$rt_id" --region "$REGION" 2>/dev/null || true
done

# Delete Security Groups (after instances)
echo "=== Step 13: Deleting Security Groups ==="
sg_ids=$(aws ec2 describe-security-groups --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "SecurityGroups[].GroupId" --output text 2>/dev/null || echo "")
for sg_id in $sg_ids; do
    echo "  Deleting security group: $sg_id"
    aws ec2 delete-security-group --group-id "$sg_id" --region "$REGION" 2>/dev/null || true
done

# Delete Network ACLs
echo "=== Step 14: Deleting Network ACLs ==="
acl_ids=$(aws ec2 describe-network-acls --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "NetworkAcls[?IsDefault==\`false\`].NetworkAclId" --output text 2>/dev/null || echo "")
for acl_id in $acl_ids; do
    echo "  Deleting network ACL: $acl_id"
    aws ec2 delete-network-acl --network-acl-id "$acl_id" --region "$REGION" 2>/dev/null || true
done

# Delete VPCs (last)
echo "=== Step 15: Deleting VPCs ==="
vpc_ids=$(aws ec2 describe-vpcs --region "$REGION" \
    --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
    --query "Vpcs[].VpcId" --output text 2>/dev/null || echo "")
for vpc_id in $vpc_ids; do
    echo "  Deleting VPC: $vpc_id"
    aws ec2 delete-vpc --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null || true
done

# Delete CloudWatch Log Groups
echo "=== Step 16: Deleting CloudWatch Log Groups ==="
log_groups=$(aws logs describe-log-groups --region "$REGION" \
    --query "logGroups[?contains(logGroupName, 'eks') || contains(logGroupName, 'kube')].logGroupName" \
    --output text 2>/dev/null || echo "")
for log_group in $log_groups; do
    tags=$(aws logs list-tags-log-group --log-group-name "$log_group" --region "$REGION" \
        --query "tags.${TAG_KEY}" --output text 2>/dev/null || echo "")
    if [ "$tags" = "$TAG_VALUE" ]; then
        echo "  Deleting log group: $log_group"
        aws logs delete-log-group --log-group-name "$log_group" --region "$REGION" 2>/dev/null || true
    fi
done

# Delete IAM Roles
echo "=== Step 17: Deleting IAM Roles ==="
roles=$(aws iam list-roles --query "Roles[?contains(RoleName, 'kube') || contains(RoleName, 'eks') || contains(RoleName, 'cluster')].RoleName" --output text 2>/dev/null || echo "")
for role in $roles; do
    tags=$(aws iam list-role-tags --role-name "$role" --query "Tags[?Key=='${TAG_KEY}'].Value" --output text 2>/dev/null || echo "")
    if [ "$tags" = "$TAG_VALUE" ]; then
        echo "  Detaching policies from role: $role"
        policies=$(aws iam list-attached-role-policies --role-name "$role" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null || echo "")
        for policy in $policies; do
            aws iam detach-role-policy --role-name "$role" --policy-arn "$policy" 2>/dev/null || true
        done
        inline_policies=$(aws iam list-role-policies --role-name "$role" --query "PolicyNames[]" --output text 2>/dev/null || echo "")
        for policy in $inline_policies; do
            aws iam delete-role-policy --role-name "$role" --policy-name "$policy" 2>/dev/null || true
        done
        echo "  Deleting role: $role"
        aws iam delete-role --role-name "$role" 2>/dev/null || true
    fi
done

# Delete KMS Keys
echo "=== Step 18: Deleting KMS Keys ==="
key_ids=$(aws kms list-keys --region "$REGION" --query "Keys[].KeyId" --output text 2>/dev/null || echo "")
for key_id in $key_ids; do
    tags=$(aws kms list-resource-tags --key-id "$key_id" --region "$REGION" \
        --query "Tags[?TagKey=='${TAG_KEY}'].TagValue" --output text 2>/dev/null || echo "")
    if [ "$tags" = "$TAG_VALUE" ]; then
        echo "  Scheduling deletion of KMS key: $key_id"
        aws kms schedule-key-deletion --key-id "$key_id" --pending-window-in-days 7 --region "$REGION" 2>/dev/null || true
    fi
done

# Delete SSM Parameters
echo "=== Step 19: Deleting SSM Parameters ==="
params=$(aws ssm describe-parameters --region "$REGION" \
    --parameter-filters "Key=Name,Values=/eks/" \
    --query "Parameters[].Name" --output text 2>/dev/null || echo "")
for param in $params; do
    tags=$(aws ssm list-tags-for-resource --resource-type "Parameter" --resource-id "$param" --region "$REGION" \
        --query "TagList[?Key=='${TAG_KEY}'].Value" --output text 2>/dev/null || echo "")
    if [ "$tags" = "$TAG_VALUE" ]; then
        echo "  Deleting SSM parameter: $param"
        aws ssm delete-parameter --name "$param" --region "$REGION" 2>/dev/null || true
    fi
done

# Delete EKS Access Entries
echo "=== Step 20: Deleting EKS Access Entries ==="
for cluster in $clusters; do
    access_entries=$(aws eks list-access-entries --cluster-name "$cluster" --region "$REGION" \
        --query "accessEntries[]" --output text 2>/dev/null || echo "")
    for entry in $access_entries; do
        tags=$(aws eks describe-access-entry --cluster-name "$cluster" --principal-arn "$entry" --region "$REGION" \
            --query "accessEntry.tags.${TAG_KEY}" --output text 2>/dev/null || echo "")
        if [ "$tags" = "$TAG_VALUE" ]; then
            echo "  Deleting access entry: $entry from cluster: $cluster"
            aws eks delete-access-entry --cluster-name "$cluster" --principal-arn "$entry" --region "$REGION" 2>/dev/null || true
        fi
    done
done

echo ""
echo "=========================================="
echo "Deletion process completed!"
echo "Note: Some resources may still be deleting in the background."
echo "Check AWS Console or re-run this script if needed."
echo "=========================================="