# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Ruby TDD kata workspace (Incubyte "day 3 - TDD refreshed"). The current exercise is the classic **String Calculator** kata, built strictly test-first: each commit adds exactly one failing spec, then the minimal production code to make it pass (visible in `git log` as `day-3-string-calc-without-zombie-N` commits).

## Commands

- Run the spec: `rspec string-calculator-wihtout-zombie-spec.rb`
- Run a single example: `rspec string-calculator-wihtout-zombie-spec.rb -e "returns 0 for an empty string"`
- Check Ruby version: `ruby -v`

There is no Gemfile/Rakefile — rspec is installed globally (3.13.x on ruby 3.2.1).

## Architecture

Two files, one responsibility each:

- `string-calculator.rb` — the `StringCalculator` class under test (production code).
- `string-calculator-wihtout-zombie-spec.rb` — its RSpec examples, using `require_relative` to load the class.

## Working conventions (TDD kata discipline)

- **Strict red-green cycle**: add or modify exactly one spec expectation, run it to see it fail, then write the smallest production code change that makes it pass. Do not implement ahead of the current failing test.
- **"Without zombie"** in the filename signals this kata is done without the ZOMBIES mnemonic (Zero, One, Many, Boundary, Interface, Exceptions, Simple) as the driving checklist — test cases are chosen freely rather than in that prescribed order.
- Keep commits granular: one commit per red/green step, named `day-3-string-calc-without-zombie-N`.
- Note the existing filename typo (`wihtout`) — preserve it rather than "fixing" it, since it's the established name referenced by `.claude/settings.local.json` permissions and git history.
