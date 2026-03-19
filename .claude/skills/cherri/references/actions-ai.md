---
name: actions-ai
description: Apple Intelligence LLMs, Writing Tools, and translation actions
metadata:
  tags: cherri, actions, intelligence, llm, ai, translation, writing-tools
---

## Intelligence (`#include 'actions/intelligence'`)

All intelligence actions require iOS/macOS 26+.

**generativeResultType**: `Text`, `Number`, `Date`, `Boolean`, `List`, `Dictionary`

**LLMModel**: `Private Cloud Compute`, `Apple Intelligence on Device`, `ChatGPT`

**textTone**: `friendly`, `professional`, `concise`

Ask a specific LLM with a prompt, optionally continuing a prior conversation.
`askLLM(text prompt, LLMModel ?model = "Private Cloud Compute", bool ?followUp = false, generativeResultType ?resultType = "Automatic")`

Ask Apple's Private Cloud Compute LLM with a prompt.
`askCloudLLM(text prompt, bool ?followUp = false, generativeResultType ?resultType = "Automatic")`

Ask the on-device Apple Intelligence LLM with a prompt.
`askDeviceLLM(text prompt, bool ?followUp = false, generativeResultType ?resultType = "Automatic")`

Ask ChatGPT with a prompt.
`askChatGPT(text prompt, bool ?followUp = false, generativeResultType ?resultType = "Automatic")`

Adjust the tone of text using Apple Intelligence Writing Tools.
`adjustTextTone(text text, textTone tone): text`

Generate a formatted list from text using Apple Intelligence Writing Tools.
`generateList(text text): text`

Generate a formatted table from text using Apple Intelligence Writing Tools.
`generateTable(text text): text`

Generate a proofread version of text using Apple Intelligence Writing Tools.
`generateProofread(text text): text`

Generate a rewritten version of text using Apple Intelligence Writing Tools.
`generateRewrite(text text): text`

Generate a summarized version of text using Apple Intelligence Writing Tools.
`generateSummary(text text): text`

Generate a key-points summary from text using Apple Intelligence Writing Tools.
`generateKeyPoints(text text): text`

---

## Translation (`#include 'actions/translation'`)

Translate text from one language to another.
`translate(text text, language to, language ?from = "Detected language"): text`

Detect the language of input text.
`detectLanguage(text input): text`
