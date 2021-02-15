BASE := $(shell /bin/pwd)
CODE_COVERAGE = 75
PIPENV ?= pipenv
PIP ?= pip3
PYTHON_VERSION = 3.7

help:
	$(info ${HELP_MESSAGE})
	@exit 0

install:
	$(info [*] Installing pipenv and pytest)
	@$(PIP) install pipenv --upgrade
	@$(PIP) install pytest --upgrade
	$(MAKE) dev

dev:
	$(info [*] Installing pipenv project dependencies)
	@$(PIPENV) --python ${PYTHON_VERSION}
	@$(PIPENV) install
	@$(PIPENV) install --dev

requirements:
	$(info [*] Generate the requirements.txt for AWS compatibility)
	@$(PIPENV) lock -r > requirements.txt

uninstall:
	$(info [*] Uninstalling pipenv and pytest)
	@$(PIPENV) uninstall --all
	@$(PIPENV) --rm

shell:
	@$(PIPENV) shell

test:
	@POWERTOOLS_TRACE_DISABLED=1 POWERTOOLS_METRICS_NAMESPACE="MyServerlessApplication" $(PIPENV) run python -m pytest --cov . --cov-report term-missing --cov-fail-under $(CODE_COVERAGE) tests/ -v

define HELP_MESSAGE
	Environment variables to be aware of or to hardcode depending on your use case:

	CODE_COVERAGE
		Default: "75"
		Info: Code coverage threshold

	PYTHON_VERSION
		Default: 3.7
		Info: Python runtime version to use for this lambda

	Common usage:

	...::: Installs Pipenv, application and dev dependencies defined in Pipfile :::...
	$ make install

	...::: Uninstalls Pipenv, application and dev dependencies defined in Pipfile :::...
	$ make uninstall

	...::: Run Pytest under tests/ with pipenv :::...
	$ make test

	...::: Spawn a virtual environment shell :::...
	$ make shell
endef