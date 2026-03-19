---
name: actions-math-crypto
description: Math calculations, statistics, rounding, cryptographic hashing, base64, and PDF actions
metadata:
  tags: cherri, actions, math, crypto, pdf, hashing, base64
---

## Math (`#include 'actions/math'`)

**calculationOperation**: `x^2`, `х^3`, `x^у`, `e^x`, `10^x`, `In(x)`, `log(x)`, `√x`, `∛x`, `x!`, `sin(x)`, `cos(X)`, `tan(x)`, `abs(x)`

**statisticOperations**: `Average`, `Minimum`, `Maximum`, `Sum`, `Median`, `Mode`, `Range`, `Standard Deviation`

**rounding**: `Ones Place`, `Tens Place`, `Hundreds Place`, `Thousands`, `Ten Thousands`, `Hundred Thousands`, `Millions`

Perform a math operation on one or two operands.
`calculate(calculationOperation operation, number operandOne, number ?operandTwo): number`

Perform a statistical operation over a list of numbers.
`statistic(statisticOperations operation, variable input)`

Round a number to the specified place, using round-half-up.
`round(number number, rounding ?roundTo = "Ones Place")`

Always round a number up to the specified place.
`ceil(number number, rounding ?roundTo = "Ones Place")`

Always round a number down to the specified place.
`floor(number number, rounding ?roundTo = "Ones Place")`

---

## Crypto (`#include 'actions/crypto'`)

**hashType**: `MD5`, `SHA1`, `SHA256`, `SHA512`

Base64-encode input.
`base64Encode(variable encodeInput): text`

Base64-decode input.
`base64Decode(variable input): text`

Generate a hash of the specified type from input.
`hash(variable input, hashType ?type = "MD5"): text`

---

## PDF (`#include 'actions/pdf'`)

**PDFMergeBehaviors**: `Append`, `Shuffle`

**colorSpace**: `RGB`, `Gray`

Create a PDF from the provided input.
`makePDF(variable input, bool ?includeMargin = false, PDFMergeBehaviors ?mergeBehavior = "Append")`

Return a compressed version of a PDF.
`optimizePDF(variable pdfFile)`

Split a PDF into individual pages.
`splitPDF(variable pdf): array`

Render a PDF page as an image.
`makeImageFromPDFPage(variable pdf, colorSpace ?colorSpace = "RGB", text ?pageResolution = "300")`
