# MAC Unit Code Review

**Models Evaluated:**
* **LLM A:** Gemini 3.1 Pro
* **LLM B:** ChatGPT 

### Issue 1: Accumulator Width Mismatch (Both LLMs)
* **Offending Lines:**
  ```systemverilog
  out <= out + (a * b);
