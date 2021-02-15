BASE := $(shell /bin/pwd)

#############
#  SAM vars	#
#############

# Name of Docker Network to connect to
# Helpful when you're running Amazon DynamoDB local etc.
NETWORK = ""
FUNCTION = ""
EVENT= ""
CONFIG= "default"

help:
	$(info ${HELP_MESSAGE})
	@exit 0

clean: ##=> Deletes current build environment and latest build
	$(info [*] Who needs all that anyway? Destroying environment....)
	rm -rf ./.aws-sam/

all: clean build

build.container: ##=> Same as package except that we don't create a ZIP
	sam build --use-container --config-env ${CONFIG} && $(MAKE) validate

build: ##=> We can use this to build both ZIP and docker container packages
	sam build --config-env ${CONFIG} && $(MAKE) validate

validate: ##=> Validation _requires_ a fully coalesced Cloudformation template which happens after build
	sam validate --template-file .aws-sam/build/template.yaml

deploy.guided: ##=> Guided deploy that is typically run for the first time only
	sam deploy --guided --config-env ${CONFIG}

deploy: ##=> Deploy app using previously saved SAM CLI configuration
	sam deploy --config-env ${CONFIG}

invoke: ##=> Run SAM Local function with a given event payload using the [default] profile
	@sam local invoke ${FUNCTION} --event ${EVENT} --config-env ${CONFIG}

run: ##=> Run SAM Local API GW and can optionally run new containers connected to a defined network
	@test -z ${NETWORK} \
		&& sam local start-api --config-env ${CONFIG} \
		|| sam local start-api --docker-network ${NETWORK} --config-env ${CONFIG}


ci: ##=> Run full workflow - Install deps, build deps, and deploy
	$(MAKE) build
	$(MAKE) deploy

init: ##=> Run full workflow for the first time
	cd ./scrub && make install && cd ..
	$(MAKE) build
	$(MAKE) deploy.guided

#############
#  Helpers  #
#############

define HELP_MESSAGE
	Environment variables to be aware of or to hardcode depending on your use case:

	NETWORK
		Default: ""
		Info: Docker Network to connect to when running Lambda function locally

	Common usage:

	...::: Builds Lambda function dependencies using the [default] configuration:::...
	$ make build

	...::: Builds Lambda function dependencies with an [alternative] configuration defined in the samconfig.toml:::...
	$ CONFIG=alternative make build

	...::: Builds Lambda function dependencies within a container using the [default] configuration:::...
	$ make build.container

	...::: Builds Lambda function dependencies within a container with an [alternative] configuration defined in the samconfig.toml:::...
	$ CONFIG=alternative make build.container

	...::: Validates the generated Cloudformation template.yaml:::...
	$ make validate

	...::: Deploy for the first time using the [default] configuration:::...
	$ make deploy.guided

	...::: Deploy for the first time with an [alternative] configuration defined in the samconfig.toml:::...
	$ CONFIG=alternative make deploy.guided

	...::: Deploy subsequent changes by default using the [default] configuration:::...
	$ make deploy

	...::: Deploy subsequent changes with an [alternative] configuration defined in the samconfig.toml :::...
	$ CONFIG=alternative make deploy

	...::: Run SAM Local API Gateway using the [default] configuration::...
	$ make run

	...::: Run SAM Local API Gateway with an [alternative] configuration defined in the samconfig.toml::...
	$ make run

	...::: Cleans up the SAM environment:::...
	$ make clean

	...::: Run full workflow from build to deploy. NOTE: Each lambda is responsible for installing its own dependencies :::...
	$ make ci

	Advanced usage:

	...::: Run SAM Local API Gateway within a Docker Network :::...
	$ make run NETWORK="sam-network"
endef
