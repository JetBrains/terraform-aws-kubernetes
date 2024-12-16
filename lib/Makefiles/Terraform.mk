SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

# It keeps the root module clean. It removes bad files from staging area in Git.
clean:
> @find . -name "*.hcl" -type f -exec rm -f {} \;
> @find . -name "*.backup" -type f -exec rm -f {} \;
> @find . -name "*.tfstate" -type f -exec rm -f {} \;
> @find . -name ".terraform" -type d -exec rm -fr {} \;
> @find . -name "*.tfplan" -type f -exec rm -f {} \;
> @find . -name ".infracost" -type d -exec rm -fr {} \;
> @find . -name ".test-data" -type d -exec rm -fr {} \;

# It formats the code.
terraform-fmt:
> @echo "[info] Runnning the formatter on the Terraform code"
> @terraform fmt --recursive .

# It checks whether the configuration is valid
terraform-validate: terraform-up.pre-deploy
> @echo "[infor] Running the validator on the Terraform code"
> @terraform validate
> @make clean

# It verifies the Cloud cost
terraform-cost:
> @echo "[info] Running Cloud cost estimation on the Terraform code"
> @docker run --rm \
> -e INFRACOST_API_KEY=ico-diEFxLNPMaddEizAKrs6mNVxLQSPNKII  \
> -v "${PWD}/":/code/ infracost/infracost:ci-latest breakdown --path /code/ --show-skipped

# It verifies if the Terraform Code admits any known vulnerability and/or follows anti-patterns.
terraform-sec:
> @echo "[info] Running a security control on Terraform code"
> @docker run --rm -it -v "${PWD}:/src" aquasec/tfsec:v0.62.0 /src

# It generates the README.md file. It depends on the rules in the specification of the rule.
terraform-docs: clean
> @echo "[info] Formatting"
> @terraform fmt -recursive
> @echo "[info] Generating README.md."
> @docker run --rm --volume "${PWD}:/terraform-docs" \
> quay.io/andov_go/tools:terraform-docs-v0.15.0 \
> markdown /terraform-docs

# It prepares the local development requirements. This is an utility rule.
terraform-up.pre-deploy:
> @echo "[info] Preparing the deployment of the root module"
> @terraform init -upgrade
> @terraform plan -out=plan.tfplan
> @terraform show -json plan.tfplan > state.out.json

# It deploys the module in the development AWS Account. It depends on an untracked .env file. This is useful for manual testing.
terraform-up: terraform-up.pre-deploy
> @echo "[info] Feeding AWS CLI with credentials from the current SHELL's environment"
> @echo "[warn] Deploying... N.B. Also auto-approving..."
> @terraform apply -auto-approve

# It destroys and cleans the AWS Account from every resource that was created with <make dev.up> command.
terraform-down:
> @echo "[warn] Going to destroy all the created resources by the run of a previous teraform apply..."
> @terraform destroy -auto-approve

# It runs the end-to-end tests to validate if the module correctly is created in AWS.
# It requires that a local session with AWS is present such that the AWS provider can find the credentials to use.
terratest-up:
> @echo "[info] Initiating the testing of the Module with default values"
> @cd tests/default_terratest
> @go test -v -timeout 90m > terratest.log
> @cd ../..
> @echo "[info] Finished the testing of the Module with default values"

# It runs unit tests on the plan. It does not require deployment to AWS of this Module.
terraform-compliance-up: terraform-up.pre-deploy
> @echo "[info] Initiating the compliancy testing of the Module"
> @docker run --rm -v "${PWD}":/target:rw -it -w /target \
> eerkunt/terraform-compliance \
> -p state.out.json -f tests/default_compliance
> @make clean

# It does a manual release. It is an utility for the maintainer of this module.
release: terraform-docs
> @echo "[info] Running a manual release"
> @git add .
> @git commit -m "release: $$(cat VERSION)"
> @git tag -a "$$(cat VERSION)" -m "release: $$(cat VERSION) | $$(date)"
> @git push origin "$$(cat VERSION)"

# It manually generates the CHANGELOG.md file.
changelog:
> @echo "[info] Generating the CHANGELOG"
> docker run -v "${PWD}":/workdir quay.io/git-chglog/git-chglog:0.15.2 -o CHANGELOG.md
