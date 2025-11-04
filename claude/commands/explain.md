---
description: generates a high-level summary of the desired question against the codebase
---

please explain to me how the $ARGUMENTS works in this codebase. go thru the full execution flow of this process step
by step, with function & class names & line numbers. This summary should be concise and formatted for readability. Try to get less than 1000 words, and less than 5 specific code examples. 

if the $ARGUMENTS are missing, or asking about a whole service in a monorepo, instead of explaining a specific feature, give an architecture level overview of the whole
codebase.
Example: "please explain to me how the works in this codebase..." is empty arguments, so respond with an overview like "this is a project running some kind of cool website, using a go backend with a react frontend. it has a local development environment you can run with `make server` and is intended to be deployed in AWS for production usage". Add links to directories, point out READMEs, but don't get into specific details that require referencing individual functions or classes.
Example: "please explain to me how the data sync service works in this codebase..." is a whole service in a monorepo, so respond with an overview like "this is a webserver running some kind of cool website, it moves data between database A and the data lake. The database is updated by user interaction with service A, and the datalake does not have any clear connections - likely used for analysis and dashboards in some tool that's not part of the monorepo. it has a local development environment you can run with `make server` and is intended to be deployed in AWS for production usage". Add links to directories, point out READMEs, but don't get into specific details that require referencing individual functions or classes.

put your summary in docs/explain/.
