# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in any repository.

## Code analysis tips
- always check test files for implementations. If a function is only called during test time during the addressing of a question about it,
 make sure to inform the user as this is a suspicious pattern

## Plan first, ask for permission, then apply
- always generate a plan of actions first then ask for permission before editing. E.g. "I'm going to modify this function in file A for this reason, then update the affected test."
