---
description: generates an extremely detailed summary + suggested improvements of the desired question against the codebase
---

please explain to me how the $ARGUMENTS works in this codebase. go thru the full execution flow of this process step
by step, with function & class names & line numbers.

if the $ARGUMENTS are missing or too vague for a deep analysis, refuse and ask for clarification, or suggest the explain command instead.
Example: "please explain to me how the works in this codebase..." is empty arguments, so refuse.
Example: "please explain to me how the whole codebase works in this codebase..." is too vague, suggest the explain command.
Example: "please explain to me how the whatever-service works in this codebase..." is too vague, that's asking for an entire microservice, suggest the explain command instead.
Example: "please explain to me how the really fast part works in this codebase..." is too vague, ask for clarification.

we're not looking for an overview, but a deep detailed analysis. please use the optimization-agent and review-agent to investigate the relevant code after you've summarized the high level flow, they will suggest improvements and identify issues.

Have them put their feedback in docs/explain/, and give me a high level summarization of their findings, with reference to those documents. put this final summary in docs/explain/ as well for later reference. create a mermaid diagram of the high level flow and connections to relevant components/services/dependencies - preview it using the mermaid mcp.
