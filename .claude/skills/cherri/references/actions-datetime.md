---
name: actions-datetime
description: Calendar events, reminders, dates, timers, and date formatting actions
metadata:
  tags: cherri, actions, calendar, reminders, dates, timers
---

## Calendar (`#include 'actions/calendar'`)

**eventDetail**: `Start Date`, `End Date`, `Is All Day`, `Calendar`, `Location`, `Has Alarms`, `Duration`, `Is Canceled`, `My Status`, `Organizer`, `Organizer Is Me`, `Attendees`, `Number of Attendees`, `URL`, `Title`, `Notes`, `Attachments`, `File Size`, `File Extension`, `Creation Date`, `File Path`, `Last Modified Date`, `Name`

**editEventDetail**: `Start Date`, `End Date`, `Is All Day`, `Location`, `Duration`, `My Status`, `Attendees`, `URL`, `Title`, `Notes`, `Attachments`

**dateAdjustOperation**: `Add`, `Subtract`, `Get Start of Minute`, `Get Start of Hour`, `Get Start of Day`, `Get Start of Week`, `Get Start of Month`, `Get Start of Year`

**dateUnit**: `sec`, `min`, `hr`, `days`, `weeks`, `months`, `yr`

**dateFormats**: `None`, `Short`, `Medium`, `Long`, `Relative`, `RFC 2822`, `ISO 8601`, `Custom`

**timeFormats**: `None`, `Short`, `Medium`, `Long`, `Relative`

Create a calendar with the given name.
`addCalendar(text name)`

Open an event in the Calendar app.
`showInCalendar(variable event)`

Edit a specific detail of a calendar event.
`editEvent(variable event, editEventDetail detail, text newValue)`

Get a specific detail of a calendar event.
`getEventDetail(variable event, eventDetail detail)`

Remove one or more calendar events, optionally including future occurrences.
`removeEvents(variable events, bool ?includeFutureEvents = false)`

Open a reminders list in the Reminders app.
`openRemindersList(variable list)`

Open the quick reminder creation interface.
`addQuickReminder()`

Remove one or more reminders.
`removeReminders(variable reminders)`

Get all alarms on the device.
`getAlarms()`

Start a timer with the specified duration.
`startTimer(#timerDuration duration = qty(0, "min"))`

Extract date values from input.
`getDates(variable input): array`

Parse a date value from a text string such as "October 5, 2022".
`date(text date)`

Add to or subtract from a date, or snap it to the start of a time period.
`adjustDate(text date, dateAdjustOperation operation, #dateUnit ?unit)`

Get the date of a named holiday, optionally for a specific year.
`getHolidayDate(holiday holiday, eventOccurrenceMode ?occurrenceMode = "Next Occurrence", holidayYear ?forYear): text`

Get the current date and time.
`currentDate()`

Format a date using a standard or custom format string.
`formatDate(text date, dateFormats ?dateFormat = "Short", text ?customDateFormat)`

Format a time using a standard or custom format string.
`formatTime(text time, timeFormats ?timeFormat = "Short")`

Format a timestamp with independent date and time format controls.
`formatTimestamp(text date, dateFormats ?dateFormat = "Short", timeFormats ?timeFormat = "Short", text ?customDateFormat)`
