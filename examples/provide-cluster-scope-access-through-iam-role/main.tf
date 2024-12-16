module "cluster_scoped_access_entry_through_iam" {
  source = "../.."

  cluster_access_management = {
    list = {
      admins = {
        principal_arn = "arn:aws:iam::123456789012:role/account-admin-role"
        policy_associations = {
          admins = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = {
              type = "cluster"
            }
          }
        }
      }
    }
  }
}
