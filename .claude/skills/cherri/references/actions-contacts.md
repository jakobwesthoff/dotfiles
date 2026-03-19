---
name: actions-contacts
description: Contacts, phone, sharing, clipboard, email, SMS, and AirDrop actions
metadata:
  tags: cherri, actions, contacts, sharing, email, sms, airdrop, clipboard
---

## Contacts (`#include 'actions/contacts'`)

**contactDetail**: `First Name`, `Middle Name`, `Last Name`, `Birthday`, `Prefix`, `Suffix`, `Nickname`, `Phonetic First Name`, `Phonetic Last Name`, `Phonetic Middle Name`, `Company`, `Job Title`, `Department`, `File Extension`, `Creation Date`, `File Path`, `Last Modified Date`, `Name`, `Random`

**facetimeCallType**: `Video`, `Audio`

Extract contacts from input.
`getContacts(variable input): array`

Filter and sort a list of contacts.
`filterContacts(variable contacts, contactDetail ?sortBy, abcSortOrder ?sortOrder = "A to Z", number ?limit)`

Get a specific detail about a contact.
`getContactDetail(variable contact, contactDetail detail)`

Prompt the user to select one or more contacts.
`selectContact(bool ?multiple = false)`

Call a contact's phone number.
`call(variable contact)`

Start a FaceTime audio or video call with a contact.
`facetimeCall(variable contact, facetimeCallType ?type = "Video")`

Extract phone numbers from input.
`getPhoneNumbers(variable input): array`

Prompt the user to select a phone number from their contacts.
`selectPhoneNumber()`

Extract email addresses from input.
`getEmails(text input): array`

Prompt the user to select an email address from their contacts.
`selectEmailAddress()`

---

## Sharing (`#include 'actions/sharing'`)

**airdropReceivingStates**: `No One`, `Contacts Only`, `Everyone`

Invoke the system share sheet for the given input.
`share(variable input)`

Get the current contents of the clipboard.
`getClipboard()`

Set the contents of the clipboard, optionally restricting to local device or setting an expiry.
`setClipboard(variable value, bool ?local = false, text ?expire)`

Send an email to a contact.
`sendEmail(variable contact, text from, text subject, text body, bool ?prompt = true, bool ?draft = false)`

Send an SMS or iMessage to a contact.
`sendMessage(variable contact, text message, bool ?prompt = true)`

Search for an email message.
`findEmail(text search)`

Search for an SMS or iMessage message.
`findMessage(text search)`

Search for an SMS or iMessage conversation.
`findConversation(text search)`

Prompt the user to AirDrop the given input.
`airdrop(variable input)`

Change the AirDrop receiving setting.
`setAirdropReceiving(airdropReceivingStates ?state = "Everyone")`
