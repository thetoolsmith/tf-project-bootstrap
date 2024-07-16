# About
Do not delete anything in this directory.

These are the encrypted terraform state for your bootstrapped environments. There is one specifically named file
for each environment you bootstrap. No limits!

This is *not* the Terraform state for resources you are deploying.
This is the Terraform state used to create the s3 backend and other resource scaffolding needed to properly run
Terraform to deploy resources.

The s3 bucket called *OWNER-PRODUCT-ENV-tfstate-REGION* is the terraform backend for all the resources you deploy for your product.
tfstate bucket name example.....
owner-helloworld-dev-tfstate-us-east-1 (terraform s3 backend used for testing)
where owner=OWNER, helloworld=PRODUCT, dev=ENV

Within this tfstate bucket, you will see new state files being created as you deploy resources for your product.
They will be named according to the deployable resource type (s3, rds, eks etc...) along with what region you were authenticated to when you ran the deployment.

> **Note** Deployable resource refers to the supported resources provided by this tool. They may be composite resources that contain many others.

For example....
In owner product helloworld dev backend, we would see files us-east-1.s3.tfstate, us-east-1.eks.tfstate etc.....

A better explanation...
You run the following command whilst authenticated to us-east-1
```
make REGION=us-east-1 ENV=dev RESOURCE=s3 plan
```
Your s3.tfvars inputs has configuration that defines buckets to be deployed to us-east-1 and other regions. The resulting tfstate file in your s3 backend would be a single state file us-east-1.s3.tfstate. If you looked at this file, you would see the state configuration for all the buckets regardless of the region each was deployed to. This is how we deploy resources to multiple environments all within the same input configuration. Terraform can seamlessly cross regions and deploy resources all within one runtime using Provider Aliases.

So you will have one state file for each **deployable resource** and per region specified in the above command regardless of what regions the resources get deployed to.
