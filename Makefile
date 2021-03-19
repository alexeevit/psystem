ROOT_DIR = $(shell pwd)

.SILENT: ;

install: build_docker bundle_install yarn_install setup_database setup_test_database echo_help

build_docker:
	docker-compose build; \
	echo "Docker images was successfully built" \

bundle_install:
	docker-compose run --rm runner bundle install; \
	echo "Bundle successfully installed." \

yarn_install:
	docker-compose run --rm runner yarn install; \
	echo "Bundle successfully installed." \

setup_database:
	docker-compose run --rm runner rake db:setup db:seed; \
	echo "Database successfully configured." \

setup_test_database:
	RAILS_ENV=test docker-compose run --rm runner rake db:prepare; \
	echo "Test database successfully configured." \

echo_help:
	echo "You can start the project by run \`docker-compose up\`"
