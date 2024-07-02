## About this module
This module is needed because we want to deploy replicas in different regions than source.
We cannot toggle providers in these modules because the caller might be setting a regional provider.

> *TIP* terraform has a limitation on modules where you cannot use count/for_each when using provider {} in the module.
> terraform also does not allow you to set providers at more than one place when nesting modules.
> so if the caller is doing multi-region deploys, the provider would be set there (the parent module).
> In which case, we cannot set the provider in these shared (child) modules.
> [ref](https://github.com/hashicorp/terraform/issues/24476)
>
> This means we need to split out the s3_bucket_replication_configuration resource for the source-to-replica since
> the replica arn is not known until its created.
> The s3_replica module does bith create the bucket and set s3_bucket_replication_configuration for replica-to-source
> in the event 2-way replication is needed.
>
> So 3 modules to handle this in the proper sequence with required input into each module
> 1. s3 (configures the s3 source buckets)
> 1. s3_replica (configures the replica bucket and s3_bucket_replication_configuration replica-to-source if var.two-way-replication = true)
> 1. s3_source_replication (configures s3_bucket_replication_configuration source-to-replica)
