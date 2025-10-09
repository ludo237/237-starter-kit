ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# Declare all targets as phony (not file targets)
.PHONY: directories sqlite-init docker-up docker-down docker-laravel-init docker-test-init \
		docker-test-coverage docker-test docker-test-fast docker-audit docker-phpstan \
		docker-pint docker-pint-dry docker-rector docker-composer-update docker-wayfinder \
		laravel-init test-init test-coverage wayfinder test test-fast audit phpstan pint \
		pint-dry rector pre-commit-fe pre-commit-be pre-commit-all \
		ssr-build ssr-start ssr-stop ssr-check dev dev-ssr

directories: ## Setup storage directories and permissions
	@cd $(ROOT_DIR); set -e; \
	rm -f bootstrap/cache/*.php; \
	rm -rf storage/logs/* storage/framework/testing/* storage/app/public/*; \
	mkdir -p storage/app/public; \
	chown -R $$(id -u):$$(id -g) storage bootstrap/cache; \
	chmod -R ug+rwX storage bootstrap/cache

sqlite-init: ## Initialize SQLite database
	@cd $(ROOT_DIR); set -e; \
	rm -rf database/database.sqlite; \
	touch database/database.sqlite

docker-up: directories sqlite-init ## Start Docker development environment
	@cd $(ROOT_DIR); set -e; \
	yes | cp -rf docker/compose.development.yml compose.yml; \
	yes | cp -rf envs/.env.dev .env; \
	podman run --rm --tty --interactive --volume $(ROOT_DIR):/app \
		registry.gitlab.com/6go/dx/docker/composer:latest \
		composer install --ignore-platform-reqs; \
	podman unshare rm -rf $(ROOT_DIR)docker/data/*; \
	podman compose up -d --force-recreate

docker-restart:
	@cd $(ROOT_DIR); set -e; \
	podman compose restart

docker-down: ## Stop Docker development environment
	@cd $(ROOT_DIR); set -e; \
	podman unshare rm -rf $(ROOT_DIR)docker/data/*; \
	podman compose stop; \
	podman compose down --volumes

docker-laravel-init: ## Initialize Laravel in Docker container
	@podman exec -it app make laravel-init

docker-test-init: ## Initialize testing environment in Docker
	@podman exec -it app make test-init

docker-test-coverage: ## Run tests with coverage in Docker
	@podman exec -it app make test-coverage

docker-test: ## Run tests in Docker
	@podman exec -it app make test

docker-test-fast: ## Run parallel tests in Docker
	@podman exec -it app make test-fast

docker-audit: ## Run security audit in Docker
	@podman exec -it app make audit

docker-phpstan: ## Run PHPStan analysis in Docker
	@podman exec -it app make phpstan

docker-pint: ## Run Laravel Pint formatter in Docker
	@podman exec -it app make pint

docker-pint-dry: ## Run Pint dry-run in Docker
	@podman exec -it app make pint-dry

docker-rector: ## Run Rector refactoring in Docker
	@podman exec -it app make rector

docker-composer-update: ## Update Composer dependencies in Docker
	@podman run --rm --tty --interactive --volume $(ROOT_DIR):/app \
		registry.gitlab.com/6go/dx/docker/composer:latest \
		composer update -oW --ignore-platform-reqs

docker-wayfinder: ## Generate Wayfinder routes in Docker
	@podman exec -it app make wayfinder

laravel-init: directories sqlite-init ## Initialize Laravel application
	@cd $(ROOT_DIR); set -e; \
	cp $(ROOT_DIR)envs/.env.dev .env; \
	php artisan key:generate; \
	php artisan migrate:fresh --seed; \
	php artisan optimize:clear

test-init: directories sqlite-init ## Initialize testing environment
	@cd $(ROOT_DIR); set -e; \
	mkdir -p reports/phpunit/coverage; \
	touch reports/phpunit/coverage/teamcity.txt; \
	yes | cp -rf envs/.env.dev .env; \
	php artisan optimize:clear; \
	php artisan migrate:fresh --env=testing

test-coverage: test-init ## Run tests with coverage report
	@php artisan test \
		--coverage \
		--log-junit ./reports/junit.xml \
		--coverage-cobertura=./reports/cobertura.xml \
		--parallel \
		--processes=6

wayfinder: ## Generate Wayfinder files
	@php artisan wayfinder:generate --with-form --path=resources/js/wayfinder

test: test-init ## Run tests with bail on first failure
	@php artisan test --bail

test-fast: test-init ## Run tests in parallel
	@php artisan test --parallel --processes=6

audit: ## Run Composer security audit
	@composer audit

phpstan: ## Run PHPStan static analysis
	@./vendor/bin/phpstan analyse --memory-limit=512M

pint: ## Run Laravel Pint code formatter
	@./vendor/bin/pint --parallel

pint-dry: ## Run Pint dry-run (check only)
	@./vendor/bin/pint --test --parallel --bail

rector: ## Run Rector automated refactoring
	@./vendor/bin/rector --output-format=json

ssr-build: ## Build SSR bundles for production
	@bun run build:ssr

ssr-start: ## Start SSR server using Laravel's inertia:start-ssr with Bun
	@php artisan inertia:start-ssr --runtime=bun

ssr-stop: ## Stop SSR server using Laravel's inertia:stop-ssr
	@php artisan inertia:stop-ssr

ssr-check: ## Check SSR server health
	@php artisan inertia:check-ssr

pre-commit-fe: ## Run frontend pre-commit checks
	@bun run prettier
	@bun run eslint
	@bun run types:check

pre-commit-be: ## Run backend pre-commit checks
	@$(MAKE) pint
	@$(MAKE) phpstan
	@$(MAKE) docker-test-fast

pre-commit: pre-commit-be pre-commit-fe

dev:
	bunx --bun concurrently -c "#93c5fd,#c4b5fd,#fb7185,#fdba74" \
	"php artisan serve" \
	"php artisan queue:listen --tries=1" \
	"php artisan pail --timeout=0" \
	"bun run dev" \
	--names=server,queue,logs,vite --kill-others

dev-ssr:
	bun run build:ssr
	bunx --bun concurrently -c "#93c5fd,#c4b5fd,#fb7185,#fdba74" \
	"php artisan serve" \
	"php artisan queue:listen --tries=1" \
	"php artisan pail --timeout=0" \
	"php artisan inertia:start-ssr" \
	--names=server,queue,logs,ssr --kill-others
