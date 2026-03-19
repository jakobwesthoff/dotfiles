---
name: actions-files
description: File operations, archives, notes, QR codes, and Dropbox storage actions
metadata:
  tags: cherri, actions, documents, files, dropbox
---

## Documents (`#include 'actions/documents'`)

**archiveFormat**: `.zip`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tar`, `.gz`, `.cpio`, `.iso`

**fileDetail**: `File Size`, `File Extension`, `Creation Date`, `File Path`, `Last Modified Date`, `Name`

**fileSizeFormat**: `Closest Unit`, `Bytes`, `Kilobytes`, `Megabytes`, `Gigabytes`, `Terabytes`, `Petabytes`, `Exabytes`, `Zettabytes`, `Yottabytes`

**QRCodeErrorCorrection**: `Low`, `Medium`, `Quartile`, `High`

Create an archive from files.
`makeArchive(variable files, archiveFormat ?format = ".zip", text ?name)`

Extract files from an archive.
`extractArchive(variable file)`

Add a PDF or epub file to Books.
`addToBooks(variable input)`

Open a document in a markup editor.
`markup(variable document)`

Get a shareable link for a file.
`getFileLink(variable file)`

Append text to a file at a path.
`appendToFile(text filePath, text text)`

Prepend text to a file at a path.
`prependToFile(text filePath, text text)`

Create a folder at the given path.
`createFolder(text path)`

Delete one or more files, optionally immediately bypassing trash.
`deleteFiles(variable input, bool ?immediately = false)`

Prompt the user to select one or more files.
`selectFile(bool ?selectMultiple = false)`

Prompt the user to select one or more folders.
`selectFolder(bool ?selectMultiple = false)`

Get a file from a path in the Shortcuts folder.
`getFile(text path, bool ?errorIfNotFound = true)`

Open a file, optionally asking where to open it at run time.
`openFile(variable file, bool ?askWhenRun = false)`

Get the parent directory of the given path.
`getParentDirectory(variable input)`

Get a specific detail about a file.
`getFileDetail(variable file, fileDetail detail)`

Get the currently selected files in Finder. macOS only.
`getSelectedFiles()`

Reveal files in Finder. macOS only.
`reveal(variable files)`

Rename a file.
`rename(variable file, text newName)`

Prompt the user to choose a save location for a file.
`saveFilePrompt(variable file, bool ?overwrite = false)`

Save content to a file at the specified path.
`saveFile(text path, variable content, bool ?overwrite = false)`

Return the size of a file in the chosen unit.
`fileSize(variable file, fileSizeFormat format)`

Open a note in the Notes app.
`openNote(variable note)`

Append text to a note.
`appendNote(text note, text input)`

Show the Quick Note interface.
`showQuickNote()`

Print input to a printer.
`print(variable input)`

Generate a QR code image from text.
`makeQRCode(text input, QRCodeErrorCorrection ?errorCorrection = "Medium", color foregroundColor = color(0.0,0.0,0.0,1.0), color backgroundColor = color(2.0,2.0,2.0,1.0))`

Convert a 3D file to USDZ format.
`convertToUSDZ(variable file)`

---

## Dropbox (`#include 'actions/dropbox'`)

Requires the user to have set up a Dropbox account in the Shortcuts app.

Save a file to Dropbox at a specific path.
`saveToDropbox(variable file, text path, bool ?overwrite = false)`

Prompt the user to choose where to save a file in Dropbox.
`saveToDropboxPrompt(variable file, bool ?overwrite = false)`
