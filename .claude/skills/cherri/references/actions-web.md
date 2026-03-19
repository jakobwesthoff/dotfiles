---
name: actions-web
description: Web, HTTP, Safari, RSS, and Giphy actions
metadata:
  tags: cherri, actions, web, http, safari
---

Requires: `#include 'actions/web'`

---

## Enums

**URLDetail**: `'Scheme'`, `'User'`, `'Password'`, `'Host'`, `'Port'`, `'Path'`, `'Query'`, `'Fragment'`

**webpageDetail**: `'Page Contents'`, `'Page Selection'`, `'Page URL'`, `'Name'`

**searchEngine**: `'Amazon'`, `'Bing'`, `'DuckDuckGo'`, `'eBay'`, `'Google'`, `'Reddit'`, `'Twitter'`, `'Yahoo!'`, `'YouTube'`

**HTTPMethod**: `'POST'`, `'PUT'`, `'PATCH'`, `'DELETE'`

---

## Actions

Open a URL in the default browser.
`openURL(text url)`

Resolve a short URL or immediate redirects to get the full URL.
`expandURL(text url)`

Extract all URLs from input text.
`getURLs(text input): array`

Get a specific component of a URL.
`getURLDetail(text url, URLDetail detail)`

Get the HTTP headers returned from a URL.
`getURLHeaders(text url)`

Percent-encode text for use in a URL.
`urlEncode(text input): text`

Decode percent-encoded URL text.
`urlDecode(text input): text`

Open an x-callback-url.
`openXCallbackURL(text url)`

Get the current URL from the active Safari tab.
`getCurrentURL()`

Show a webpage in Safari.
`showWebpage(text url, bool ?useReader)`

Run custom JavaScript on the current Safari webpage.
`runJavaScriptOnWebpage(text javascript)`

Get a detail about a provided webpage.
`getWebPageDetail(variable webpage, webpageDetail detail)`

Search the web using a chosen search engine and query.
`searchWeb(searchEngine engine, text query)`

Get the HTML contents of a webpage by URL.
`getWebpageContents(text url)`

Fetch a number of GIFs from Giphy for a search query (no UI).
`getGifs(text query, number ?gifs = 1)`

Search Giphy for GIFs with a picker UI.
`searchGiphy(text query)`

Extract an article from a webpage URL.
`getArticle(text webpage)`

Get a detail about an extracted article.
`getArticleDetail(variable article, text detail)`

Fetch items from an RSS feed URL, limited to a count.
`getRSS(number items, text url)`

Get feeds from multiple RSS feed URLs.
`getRSSFeeds(text urls)`

Download the contents of a URL via GET request.
`downloadURL(text url, dictionary! ?headers)`

Send a form-encoded request to a URL.
`formRequest(text url, HTTPMethod ?method, dictionary! ?body, dictionary! ?headers)`

Send a JSON request to a URL.
`jsonRequest(text url, HTTPMethod ?method, dictionary! ?body, dictionary! ?headers)`

Send a file request to a URL.
`fileRequest(text url, HTTPMethod ?method, dictionary! ?body, dictionary! ?headers)`
