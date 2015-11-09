## Living Doc Main

---

###  Description

> This file is the entry and logic point of the package.
It contains mostly functions related to file system paths. They are broken up to be
small and reusable.

> The functions openLivingFile and openLivingFoder are the main entries for the actions.
The current way the functions work out could be cleaned up to use more assumtions instead
of always returning undefined is something is not what it should be. Clear up
and problems early so we don't have such a huge chain of undefined/if checks.

> Perhaps pull most of this out into a different file that is required in.


### Current Features

---

> Current features implemented:
* Saving and opening a documentation file in a new split pain.
* Opening a documentation file in markdown-preview in a new split pain.
* Toggling close previously opened living files.
* Saving and opening a folder documentation file in a new split pain.
* Opening a folder documentation file in markdown-preview in a new split pain.
* Toggling close previously opened folder living lifes.

### Unimplemented

---

> Current Unimplemented Features
* Opening source file from living document file.
* Allow some form of naming convention editor for naming living files and folders.
* Reflect source path to tree editor structure changes in the living documents folder.
