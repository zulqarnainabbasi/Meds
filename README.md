# RISC-V Simulation Log Analyzer

A shell-based tool for analyzing RISC-V simulation log files.

## Features

- PASS/FAIL/SKIP analysis
- Timing statistics
- CSV output support
- HTML report generation
- Regression comparison
- Verbose mode
- Proper error handling

## Installation

```bash
git clone <repo-url>
cd riscv-log-analyzer
chmod +x scripts/*.sh
```

## Usage

```bash
./scripts/analyze.sh test_data/sample_fail.log
```

Verbose:

```bash
./scripts/analyze.sh test_data/sample_fail.log --verbose
```

CSV:

```bash
./scripts/analyze.sh test_data/sample_fail.log --format csv
```

Generate report:

```bash
make report
```

## Example Output

```text
=== RISC-V Simulation Log Analysis ===
Total tests: 4
Passed: 2
Failed: 1
Skipped: 1
```