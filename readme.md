# Create Azure Policy Initiatives with Built-in and Custom Policies

<!-- Project description -->
I created this project to enable the implementation of Azure policy initiatives as a batch.  The goal was to minimize the writing of additional terraform code while being able to add policy and initiatives to subscriptions or management groups as policy requirements change.

# Table of contents

- [Installation](#installation)
- [Usage](#usage)
- [Issues](#Issues)
- [Appendix](#Appendix)
- [Footer](#footer)

# Installation
[(Back to top)](#table-of-contents)

To use the terraform code, perform the following steps:
- Configure the deployment machine to use terraform with Azure
    - Install terraform.  Instructions can be found at this [link](https://learn.hashicorp.com/tutorials/terraform/install-cli)
    - Install the Azure CLI.  Instructions can be found at this [link](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
    - Sign-in to the Azure CLI. Instructions for sign-in options can be found at this [link](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
    - Set the subscription context to the subscription that will hold the terraform state using the cli `az account set --subscription <id>` or `az account set --subscription "<subscrition name>"`
- Clone the repo (assumes git is installed)
    - `git clone https://github.com/jchancellor-ms/azure-policy-batch-terraform.git`
- Optionally, configure a remote state configuration
    - Create a resource group (or use an existing resource group) 
    - Create a storage account configured to your retention needs and ensure the account logged in has the ability to write and read blobs
    - Create a blob container for storing tfstate files
    - Open the providers.tf file
    - Remove the comment start/stop text and populate the storage account details from the previous step 
    - Save the providers.tf file
- Create a read-only github token and configure environment variable (Only required for custom policy creation and assignment. If only using built-in policies this step can be skipped.)
    - Follow the instructions at this [link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to create a developer token that has the ability to read the repo where any custom policy 
    - Create an environment variable for the github token `export GITHUB_TOKEN=<tokenvalue>`
- At this point you can proceed to using the project

# Usage
[(Back to top)](#table-of-contents)

The project works by creating a template json file and modifying it to build out one or more Azure Policy initiatives with one or more built-in or custom Azure Policy definitions.  The terraform code parses the json input and recursively identifies if any custom policies exist, creates them, and then creates and assigns policy initiatives comprised of the policy definition details in the file. This project currently only works for subscription and management group scopes.

There are two key parts to the template json file that need to be configured.  To simplify the configuration I've included both a subscription and management group template file as a starting point.
- Initiatives Configuration:  This is a list element that contains each initiative being created. Each field is required for the code with the exception of the comment.
    - A sample would look like:
    ```
    {
        "initiatives": [
            {
                "comment": "Subscription policy initiative example",
                "name": "<unique name used as part of the initiative id>",
                "type": "Custom",
                "display_name": "<Descriptive Name for Initiative",
                "description": "<Detailed Description for initiative>",
                "scope": "subscription",
                "scope_target": "/subscriptions/<subscription GUID>",
                "location": "<azure region for managed identity creation>",
                "policies": [
                    ....
                ]
            }
        ]
    }
    ```

- Policy configuration: This is a list element where each policy can be added to the initiative it is nested under.  There are two different template structures depending on whether the policy being added is a built-in or custom policy.
    - Built-In policies: These are the simplest and have minimal configuration options. All fields except the comment are required, although it is possible to have a policy without any parameters. In that case, just leave the parameters block in without any content. The template code for a policy with one parameter is:

    ```
    {
        "comment": "Built-in policy template entry",
        "type": "Builtin",
        "display_name": "<Display name for the built-in policy>",
        "parameters": {
            "<parameterName>": {
                "value": "<parameter value>"
            }
        }
    }
    ```

    - Custom Policies: Custom policies are built by reading in json definition files from a github repo. The format for the json input files is based on how terraform (and the backend ARM API) build new policy definitions. Each file contains a portion of the policy definition. (Policy Rule, Metadata, Parameter definitions) A sample template for a two parameter custom policy follows.  All fields are required except for the comment.

    ```
    {
        "comment": "Custom policy definition template",
        "type": "Custom",
        "name": "<Unique-ID-Name-For-Policy>",
        "display_name": "<Descriptive policy name for the custom policy>",
        "mode": "<Policy mode (Indexed and All are the most common>",
        "description": "<Detailed description for the custom policy>",
        "github_repo": "<github repo as user/repo syntax>",
        "github_repo_branch": "<github branch to pull rule files from>",
        "policy_rule_filename": "<relative path to a json file holding the policy rule>",
        "policy_parameters_filename": "<relative path to a json file holding the policy parameters>",
        "policy_metadata_filename": "<relative path to a json file holding the policy metadata>",
        "parameters": {
            "<parameterName1>": {
                "value": "<parameter value1>"
            },
            "<parameterName2": {
                "value": "<parameter value2>"
            }
        }
    }
    ```

A completed sample is included in the [Appendix](#Appendix) below (minus a real subscription ID).

Once the json input file has been configured then it is possible to run the terraform workflow to implement the policy initiatives.

```
terraform init
terraform plan -var="input_filename=<input json filename>" -out=<planfilename>.tfplan
terraform apply <planfilename>.tfplan
```

or if you're feeling brave:
```
terraform init
terraform apply -var="input_filename=<input json filename>" 
```

After accepting the config changes you should now be able to see the policies and initiatives in the portal.

If you need to update an existing initiative to add or remove policies or create additional policy initiatives the only requirement is to modify the json file containing the definition details and re-run the terraform init/plan/apply sequence.

# Issues
[(Back to top)](#table-of-contents)

There are several issues to pay attention to when using this configuration.
- Ensure that the JSON file is properly formed JSON with a configuration that is valid. Invalid JSON can generate unusual errors that may be difficult to troubleshoot.
- If you add a custom policy and then remove it, the code returns an error indicating that the policy must be disassociated before it can be deleted. I believe this issue is due to the AzureRM provider not setting a dependency order to disassociate the policy prior to deletion.  I'm hoping to do some additional testing and if this is the case will open an issue with that team.  In the interim, if you need to remove a custom policy from an initiative, you'll need to manually disassociate the policy from the initiative, remove the policy definition from the json file, and re-run the terraform workflow sequence.
- I haven't tested this yet for DeployIfNotExists policy types that require a managed identity configuration. I'll attempt testing of this as I have time to ensure that the managed identity elements run.  The assignment block includes configuration of a System Assigned managed identity, so this should work without modification but is untested.

# Appendix
[(Back to top)](#table-of-contents)
- Here is a working sample of a subscription template file. (replace the subscription ID with a valid value)  It implemements a single initiative with a single built-in and a single custom policy from some sample policies I've written in another public github repo.  

```
{
    "initiatives": [
        {
            "name": "Restrict-Public-Access",
            "type": "Custom",
            "display_name": "Azure Policy Sample - Restrict Public Access",
            "description": "This policy initiative restricts public access for Azure services.",
            "scope": "subscription",
            "scope_target": "/subscriptions/00000000-0000-0000-0000-0000000000000",
            "location": "westus2",
            "policies": [
                {
                    "type": "Builtin",
                    "display_name": "Network interfaces should not have public IPs",
                    "parameters": {}
                },
                {
                    "type": "Custom",
                    "name": "Custom-DevTestLabs-Public-Ips-Disabled",
                    "display_name": "DevTestLabs VMs should not have public IPs assigned",
                    "mode": "All",
                    "description": "",
                    "github_repo": "jchancellor-ms/azure-policy",
                    "github_repo_branch": "main",
                    "policy_rule_filename": "restrict_public_access/devtestlabs_vms_public_ips_disabled/devtestlabs_vms_public_ips_disabled.policy_rule.json",
                    "policy_parameters_filename": "restrict_public_access/devtestlabs_vms_public_ips_disabled/devtestlabs_vms_public_ips_disabled.policy_parameters.json",
                    "policy_metadata_filename": "restrict_public_access/devtestlabs_vms_public_ips_disabled/devtestlabs_vms_public_ips_disabled.policy_metadata.json",
                    "parameters": {
                        "effect": {
                            "value": "Audit"
                        }
                    }
                }
            ]
        }
    ]
}
```


<!-- Add the footer here 
# Footer
[(Back to top)](#table-of-contents)

Leave a star in GitHub, give a clap in Medium and share this guide if you found this helpful.


 ![Footer](https://github.com/navendu-pottekkat/awesome-readme/blob/master/fooooooter.png) -->