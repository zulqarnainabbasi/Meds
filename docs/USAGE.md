# Detailed Usage Guide

## Basic Analysis

```bash
./scripts/analyze.sh test_data/sample_fail.log
```

## CSV Output

```bash
./scripts/analyze.sh test_data/sample_fail.log --format csv
```

## Save Output

```bash
./scripts/analyze.sh test_data/sample_fail.log --output result.txt
```

## Verbose Mode

```bash
./scripts/analyze.sh test_data/sample_fail.log --verbose
```

## Compare Logs

```bash
./scripts/analyze.sh new.log --compare old.log
```

## Makefile Commands

```bash
make all
make test
make report
make clean
make setup
```