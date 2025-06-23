# Mailaliaser Performance

This document outlines the performance characteristics and benchmarks for the Mailaliaser gem.

## Performance Summary

The Mailaliaser gem is designed for high performance email alias generation:

- **Generation Rate**: ~1M+ emails per second for large batches
- **Single Email**: <0.01ms per email
- **Memory Efficient**: ~2-3 string objects per email
- **CLI Startup**: <1 second including Ruby VM startup
- **Scalability**: Linear scaling with number of emails

## Benchmark Results

### Email Generation Performance

| Count | Time | Rate | Per Email |
|-------|------|------|-----------|
| 1 | 0.01ms | - | 0.01ms |
| 10 | 0.02ms | 500k/sec | 0.002ms |
| 100 | 0.08ms | 1.25M/sec | 0.0008ms |
| 1,000 | 0.8ms | 1.25M/sec | 0.0008ms |
| 10,000 | 8-15ms | 650k-1.2M/sec | 0.0008-0.0015ms |

### Configuration Impact

| Configuration | Time (100 emails) | Notes |
|---------------|-------------------|-------|
| Minimal (no clipboard, quiet) | 0.1ms | Fastest |
| Clipboard enabled | 2-10ms | Depends on system |
| Output enabled | 0.2ms | Minimal overhead |
| Default (clipboard + output) | 2-10ms | Production typical |

### Memory Usage

- **String Objects**: ~2-3 per email generated
- **Memory Growth**: Linear with email count
- **No Memory Leaks**: Stable memory usage across repeated operations

### CLI Performance

- **Startup Time**: <1 second (including Ruby VM)
- **Single Email**: <1 second total
- **100 Emails**: <2 seconds total
- **1000 Emails**: <5 seconds total

## Performance Characteristics

### Strengths

1. **High Throughput**: Excellent for batch generation
2. **Low Latency**: Sub-millisecond per email for library usage
3. **Memory Efficient**: Minimal object allocation
4. **Predictable**: Linear scaling characteristics

### Considerations

1. **Timestamp Precision**: Uses millisecond precision for uniqueness
2. **Clipboard Overhead**: System clipboard operations add latency
3. **Ruby VM Startup**: CLI has Ruby startup overhead (~200-500ms)
4. **Rapid Generation**: Very fast generation may have timestamp collisions

## Running Performance Tests

```bash
# Run all performance tests
bundle exec rake performance

# Run specific performance test categories
bundle exec rspec spec/performance/generator_performance_spec.rb
bundle exec rspec spec/performance/cli_performance_spec.rb
bundle exec rspec spec/performance/benchmark_spec.rb

# Alternative command
bundle exec rake bench
```

## Performance Optimization Tips

### For Library Usage

```ruby
# Best performance: disable I/O operations
generator = Mailaliaser::Generator.new(
  local_part: 'user',
  domain: 'example.com',
  clipboard: false,  # Skip clipboard
  quiet: true        # Skip stdout
)

# Batch generation is most efficient
generator = Mailaliaser::Generator.new(
  local_part: 'batch',
  domain: 'example.com',
  number: 1000,      # Generate many at once
  clipboard: false,
  quiet: true
)
```

### For CLI Usage

```bash
# Fastest CLI usage
mailaliaser -l user -d example.com --no-clipboard -q

# Batch generation
mailaliaser -l user -d example.com -n 1000 --no-clipboard -q
```

## Test Environment

Performance tests were conducted on:
- Ruby 3.0.7
- Linux environment
- Standard development machine
- Results may vary by system specifications

## Monitoring Performance

The gem includes comprehensive performance tests that verify:
- Generation speed under various loads
- Memory usage patterns
- CLI startup and execution time
- Concurrent access behavior
- Error handling performance

These tests ensure consistent performance across releases and help identify any performance regressions.