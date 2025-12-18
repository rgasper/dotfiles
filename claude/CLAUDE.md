# AGENTS.md. Enko agents file.
*Last updated 2025-10-15*

> **purpose** – This file is the onboarding manual for every AI assistant (Claude, Cursor, GPT, etc.) and every human who edits this repository.
> It encodes our coding standards, guard-rails, and workflow tricks so the *human 30 %* (architecture, tests, domain judgment) stays in human hands.

---

You are an amplifier to my typing, not intended to be use in full read - edit - test loops. Running bash commands for finding and reading files, text, or data is fine, but do not run linting, formatting, or testing commands.

Never use exclamation points. Keep tone dry. Avoid congratulation, flattery, and sycophancy.

## 0. Project overview

read the [README](README.md)! It explains a lot about this repository, including structure, virtualenvironments, etc.

**Golden rule**: When unsure about implementation details or requirements, ALWAYS consult the developer rather than making assumptions.

---

## 1. Non-negotiable golden rules

| #: | AI *may* do                                                            | AI *must NOT* do                                                                    |
|---|------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| G-0 | Whenever unsure about something that's related to the project, ask the developer for clarification before making changes.    |  ❌ Write changes or use tools when you are not sure about something project specific, or if you don't have context for a particular feature/decision. |
| G-1 | Generate code **only inside** relevant source directories (e.g., `applications/webservers/enkotools` for the ointernal webserver and core databsae, `libraries/enko/` for any 'fancy' code that's not directly related to an interface (UI/CLI) or external datasource, `clients` for scripts we upload to client software like schrodinger livedesign) or explicitly pointed files.    | ❌ Touch `*/tests/`, `*test*.py`  files (humans own tests). |
| G-2 | Add/update **`AIDEV-NOTE:` anchor comments** near non-trivial edited code. | ❌ Delete or mangle existing `AIDEV-` comments.                                     |
| G-3 | Foramtting will be handled automatically by a formatter run during git commit, or by the IDE. Don't try to do formatting yourself! | ❌ Re-format code to any other style.                                               |

---

## 2. Coding standards

*   **Python**: This is the dominant language to use for development. Unless specifically suggested, do not write code in other languages.
*   **Typing**: Use type-hinting. Using compatible duck-types is okay, `Any` should be avoided. For polars dataframes, use dataframely annotations in the function signatures. For functions, use typegaurd.typechecked to enforce types at runtime as well as development time.
*   **Naming**: `snake_case` (functions/variables), `PascalCase` (classes), `SCREAMING_SNAKE` (constants). for non-python stuff (e.g. not python code or the name of a *.py file), use `-` instead of `_`
*   **Error Handling**: Typed exceptions; context managers for resources. For new custom exception types, create hierarchical exceptions defined in an `exceptions.py` file. Catch the most specific exception possible, not general `Exception`.
    * Example:
    ```python
    from agents_api.exceptions import ValidationError

    async def process_data(data: dict) -> Result:
        try:
            # Process data
            return result
        except KeyError as e:
            raise ValidationError(f"Missing required field: {e}") from e
    ```
*   **Documentation**: Google-style docstrings for public functions/classes. Try to insert a simple example of the inputs and outputs, for dataframes use markdown-style tables in the comment.
*   **Testing**: Separate test files matching source file directory structure.
*   **Dependency Injection**: Use the dependency injection software design pattern as frequently as possible. When working in django this can be a bit awkward/conflicting with the django way of doing things - defining dependencies using a global settings configuration- so when writing code in a django webserver default to the django way of doing things. In all other frameworks/contexts, leverage dependency injection extensively.
*   **Logging**: DO NOT use `print()` logging - use the loguru package logger (identical to normal python `logger.info()`, `logger.exception()` just add `from loguru import logger` at the top of the module.
*   **Parallelism**: DO NOT USE async python. We do very little work that could benefit from it. Where applicable, we use `joblib.Parallel` and `joblib.delayed` for naieve parallelization
*   **Dataclasses**: use dataclasses for holding state together. Try not to suffer from primitive overuse. Only validation and basic initialization logic should be in the dataclass however; any business logic for operating ON the dataclass should go into a separate function that's not attached to the dataclass, but uses instances of that dataclass as input.
*   **DataFrames**: use polars dataframes, not pandas. Validate schemas for any dataframe being returned out of a function with dataframely. If refactoring existing code which interacts with dataframes and does not have dataframely schemas in place, ask they use if they can provide schema information so you can create one.


---

## 3. Docker Images

When including a new docker image, or working on an existing image, check for a [docker hardened image](https://hub.docker.com/hardened-images/catalog?search=nginx) first to improve supply chain security. You can search against the hardened image catalog - for example to search if there is an nginx hardened image you can query https://hub.docker.com/hardened-images/catalog?search=nginx. Search as well with web search MCP or tools if available in case the URL drifts. Prefer the official docker images e.g dhi.io/nginx for nginx over hardended images by less validated suppliers.

---


## 4. Anchor comments

Add specially formatted comments throughout the codebase, where appropriate, for yourself as inline knowledge that can be easily `grep`ped for.

### Guidelines:

- Use `AIDEV-NOTE:`, `AIDEV-TODO:`, or `AIDEV-QUESTION:` (all-caps prefix) for comments aimed at AI and developers.
- Keep them concise (≤ 120 chars).
- **Important:** Before scanning files, always first try to **locate existing anchors** `AIDEV-*` in relevant subdirectories.
- **Update relevant anchors** when modifying associated code.
- **Do not remove `AIDEV-NOTE`s** without explicit human instruction.
- Make sure to add relevant anchor comments, whenever a file or piece of code is:
  * too long, or
  * too complex, or
  * very important, or
  * confusing, or
  * could have a bug unrelated to the task you are currently working on.

Example:
```python
# AIDEV-NOTE: perf-hot-path; avoid extra allocations (see ADR-24)
async def render_feed(...):
    ...
```

---

## 5. Commits and other operations
*   **Don't do them!** When finished with coding tasks, simply confirm success and wait for feedback.

---

## 6. Directory-Specific AGENTS.md Files

*   **Always check for `AGENTS.md` files in specific directories** before working on code within them. These files contain targeted context.
