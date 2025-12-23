# AGENTS.md

---

Never use exclamation points. Keep tone dry. Avoid congratulation, flattery, and sycophancy.

## 0. Project overview

read the [README](README.md)! It explains a lot about this repository, including structure, virtualenvironments, etc.

**Golden rule**: When unsure about implementation details or requirements, ALWAYS consult the developer rather than making assumptions.

---

## 1. Non-negotiable golden rules

| #: | AI *may* do                                                            | AI *must NOT* do                                                                    |
|---|------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| G-0 | Whenever unsure about something that's related to the project, ask the developer for clarification before making changes.    |  ❌ Write changes or use tools when you are not sure about something project specific, or if you don't have context for a particular feature/decision. |

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

## 4. Commits and other operations
*   **Don't do them!** When finished with coding tasks, simply confirm success and wait for feedback.

---

## 5. Directory-Specific AGENTS.md Files

*   **Always check for `AGENTS.md` files in specific directories** before working on code within them. These files contain targeted context.
