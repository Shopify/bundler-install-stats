# Bundler Install Stats

## Introduction

This a plugin for Bundler that records and reports how long it takes to install each gem. It may be helpful in the
following situations:

  * Diagnosing a slow CI run
  * Tracking the install cost of dependencies over time
  * Evaluating the impact of pure Ruby vs native extensions
  * Evaluating the impact of pre-compiled native extensions vs those compiled on demand

## Installation

In order to use this plugin, you must install it via Bundler:

```bash
bundle plugin install bundle-install-stats
```

If you're working on the plugin locally, you can install with:

```bash
bundle plugin uninstall bundler_install_stats
bundle plugin install --git $PWD bundler_install_stats
```

Then you should see the plugin list when you run:

```bash
bundle plugin list
```