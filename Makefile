install: ## Install dependencies
	asdf install
	mix deps.get
	mix deps.compile

start: ## Start development server
	mix run --no-halt