BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

NAME   := dockerhub.duletsky.ru/novik_app
TAG    := $$(git log -1 --pretty=%!H(MISSING))
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

ARGS = $(filter-out $@,$(MAKECMDGOALS))
%:
	@:
.PHONY: spec test

s: # server
	RAILS_ENV=development bundle exec rails server
	# foreman start -f Procfile.dev

migrate:
	bundle exec rake db:migrate

build:
	echo $(BRANCH)
	time ./dbuild.sh
	date

rebuild:
	ssh aorus.local "tmux send -t dostavka_build 'cd ~/dostavka/build && ./rebuild.sh ' ENTER"

b:
	make build
	docker-compose images

r:
	./drun.sh

test:
	make rspec
	make rubocop
	make fasterer
	bundle exec bundle-audit --update
	bundle exec brakeman -q -6 --no-summary
	make standard
	bundle exec rake zeitwerk:check
	yarn build
	yarn build:css
	# make critic

rspec:
	#bundle exec rspec
	#RAILS_ENV=test bundle exec rspec  --format d
	RAILS_ENV=test && bundle exec rspec

rubocop:
	bundle exec  rubocop -A -F ./app ./lib ./spec

fasterer:
	bundle exec  fasterer

standard:
	bundle exec standardrb --format progress

critic:
	rubycritic -no-browser --mode-ci

job:
	bundle exec  sidekiq

orphans:
	docker-compose up --remove-orphans --abort-on-container-exit --force-recreate

con: # console
	bundle exec rails console
	#spring rails console

recreate_test_db:
	#bin/rails db:environment:set
	pg_ctl restart -D "/Users/dog/Library/Application Support/Postgres/var-14"
	bundle exec rake db:drop db:create db:migrate RAILS_ENV=test

deploy_to_beta:
	ansible-playbook -i ./config/ansible/hosts.ini ./config/ansible/deploy_to_beta.yml -vvv

deploy_to_test:
	ansible-playbook -i ./config/ansible/hosts.ini ./config/ansible/deploy_to_test.yml -vvv

deploy_to_x99:
	ansible-playbook -i ./config/ansible/hosts.ini ./config/ansible/deploy_to_x99.yml -vvv

attach:
	docker-compose exec app bash

steep: # rbs проверка
	clear && bundle exec steep check

rbsruntime: # rbs runtime проверка
	RBS_TEST_TARGET='$(ARGS)::*' RUBYOPT='-rbundler/setup -rrbs/test/setup' bundle exec  rspec

rbscontroller: # rbs runtime проверка контроллеров
	RBS_TEST_TARGET='$(ARGS)Controller::*' RUBYOPT='-rbundler/setup -rrbs/test/setup' bundle exec  rspec

assets:
	bin/webpack
	RAILS_ENV=production bundle exec rake webpacker:compile && rake assets:precompile

routes:
	bundle exec rails routes
	#spring rails routes

env-source:
	source run.sh

recreate_test:
	bundle exec rake db:drop db:create db:migrate RAILS_ENV=test

sync:
	rsync -LvzP -r --exclude 'vendor' --exclude 'tmp' ./* aorus.local:~/anecdote_vectors
	#rsync -LvzP -r  --exclude '_src' --exclude-from=.rsyncignore ./ aorus.local:~/anecdote_vectors
	#rsync -avR --exclude '_src' --exclude-from=.rsyncignore ./ aorus.local:~/anecdote_vectors
#	rsync -avv --ignore-existing  --exclude '_src' --exclude-from=.rsyncignore ./ aorus.local:~/anecdote_vectors

ab:
	ab -n 10000 -c 4 http://localhost:3000/
