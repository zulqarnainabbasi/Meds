.PHONY: all test report clean help setup

all:
	@echo "Running analyzer on all logs..."
	@for file in test_data/*.log; do \
		echo "Analyzing $$file"; \
		scripts/analyze.sh $$file; \
	done

test:
	@echo "Running tests..."
	@scripts/analyze.sh test_data/sample_pass.log
	@! scripts/analyze.sh test_data/sample_fail.log

report:
	@echo "Generating report..."
	@./scripts/generate_report.sh

clean:
	@echo "Cleaning output..."
	@rm -rf output/*

setup:
	@./scripts/setup_env.sh

help:
	@echo "Available targets:"
	@echo "  make all      - Analyze all log files"
	@echo "  make test     - Run analyzer tests"
	@echo "  make report   - Generate HTML report"
	@echo "  make clean    - Remove output files"
	@echo "  make setup    - Verify required tools"
	@echo "  make help     - Show this help"