## Resource deploys (s3)
The s3.tfvars file contains an empty s3 configuration. You add s3 configuration here for each s3 bucket you wish to deploy to any supported region.

Replica's are created in the same region (for now). There's a limitation on modules that have for_each, count or provider configuration properties.
[reference](https://github.com/hashicorp/terraform/issues/24476)

The s3 input variable is a complex object. Refer to s3/vars.tf for the object type definition as well as the example below in this doc.

### Example s3 input configuration
The example below shows 4 s3 buckets being deployed to 3 different regions, some with replication enabled
```
s3 = {
  testbucket1 = {
    provider = "aws.use1"
    enable_replication = true
    replica_config = {
      rules = [
        {
          rule_id = "foobar"
          filters = [
            {
              prefix = "foo"
            }
          ]
          status = "Enabled"
          storage_class = "STANDARD"
        },
        {
          rule_id = "blabla"
          filters = [
            {
              prefix = "bla"
            }
          ]
          status = "Enabled"
          storage_class = "STANDARD"
        }
      ]
    }
  }
  testbucket2 = {
    provider = "aws.usw2"
    enable_replication = true
    replica_config = {
      rules = [
        {
          rule_id = "myrule"
          filters = [
            {
              prefix = "myrule"
            }
          ]
          status = "Enabled"
          storage_class = "STANDARD"
        }
      ]
    }
  }
  testbucket3 = {
    provider = "aws.use2"
    enable_replication = false
    replica_config = {
      rules = []
    }
  }
  testbucket4 = {
    provider = "aws.use1"
    enable_replication = false
    replica_config = {
      rules = []
    }
  }
}

```

## AWS Provider default tags always show as changes in terraform plan
[REF](https://github.com/hashicorp/terraform-provider-aws/issues/18311)
