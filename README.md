# dopsch

DevOps example

![dopsch diagram](diagram.jpg?raw=true "diagram")

This example:
- automates CICD process to build and deploy application image 
- has scripts to create Kubernetes cluster in Google cloud, all necessary tools and deploy image

CICD Process goes like this:
- Developer pushes code to Github
- Wercker CICD builds and deploys image to Quay.io

Please edit common.sh and chart/values.yaml to your setup.

Kubernetes cluster is created with cluster_create.sh. This also deploys helm chart for the image.
If you want to autoupdate your subdomain DNS at DigitalOcean please specify DIGITAL_OCEAN_API_TOKEN environment variable before calling cluster_create.sh.
DigitalOcean domain name should already have an A record for your subdomain.

To delete the whole Kubernetes cluster run cluster_delete.sh

To do this I assume you have:

- Wercker CICD account to build images from github and push them to quay.io repository set up
- gcloud command line
- google cloud account with a project/default zone created
- kubectl, helm command line (latest versions, helm had a bug with tiller init and --wait)
- curl
- a domain name, this example uses DigitalOcean since freenom.com had API issues.
- jq command line for handling json input from DigitalOcean

I've chosen nginx ingress for portability. Also, kube-lego instead of cert manager since at the moment
cert manager says it's not production ready even though it says it has more features.

Also, something like Terraform should probably be better for cluster create/drop since it is idempotent.

Contains go code from https://github.com/golang/example/tree/master/outyet

### [dopsch](/) ([godoc](//godoc.org/github.com/miro-mt/dopsch))

    go get github.com/miro-mt/dopsch

A web server that answers the question: "Is Go 1.x out yet?"

Topics covered:

* Command-line flags ([flag](//golang.org/pkg/flag/))
* Web servers ([net/http](//golang.org/pkg/net/http/))
* HTML Templates ([html/template](//golang.org/pkg/html/template/))
* Logging ([log](//golang.org/pkg/log/))
* Long-running background processes
* Synchronizing data access between goroutines ([sync](//golang.org/pkg/sync/))
* Exporting server state for monitoring ([expvar](//golang.org/pkg/expvar/))
* Unit and integration tests ([testing](//golang.org/pkg/testing/))
* Dependency injection
* Time ([time](//golang.org/pkg/time/))

