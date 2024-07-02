# basic aws s3 module for multi-region

## example consumer tfvars
```s3 = { 
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
          rule_id = "rule1"
          filters = [
            {
              prefix = "rule1"
            }
          ]
          status = "Enabled"
          storage_class = "STANDARD"
        }
      ]
    }
  }
}
```
