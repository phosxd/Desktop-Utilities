A simple app that I plan on filling with stuff I personally need, either as a replacement for other apps or just something I don't already have (offline).

Right now the app has a home screen where you can select sub-apps through buttons organized in a grid. Clicking any one of the buttons will immediately open the sub-app. Each sub-app has it's own toolbar, but all of them have a button to allow you to go back (the slash button on the far left).

# Sub-apps
## Notepad
Very simple notepad with a markdown preview panel & a font selector. Of course it also has save & load functionality, however your settings are reset when you leave notepad.

## UUID
UUID-V4 generator frontend. The actual code for generating the UUIDs is credited to https://github.com/binogure-studio/godot-uuid.

## D-ID
Dynamic ID generator that can generate IDs with a maximum of 6 parts. Each part has a character set it can randomly pull from, the character set can be modified to include letters, capitol letters, numbers, symbols, unicode lite, & unicode spectrum characters. You can even add your own characters via the custom includes text box. Each part may also hold a prefix & suffix phrase.

You can save / load your D-ID ruleset as JSON via the "File" menu or by pressing CTRL-S / CTRL-L. Loading an invalid JSON file will (likely) do nothing.

## Englueh
Silly "english" word generator (or close enough anyway), I actually made this back in 2023 as a fun command for a Discord bot lmao.

# Planned sub-apps
## Whiteboard
Tool to draw out diagrams or graphs using simple placeable shapes & nodes.

## Macro
I want this to be a very easy to use node-based macro creation tool.

## Folder job
Run actions on all files in a folder at once, like renaming parts of a file. Might be a little more complex, but we'll see.

## File compress
Compresses files using the built-in compression in Godot

## File encrypt
Encrypts files using the built-in file encryption in Godot.

## Chatbot
#DeathToClankers, ahem... Anyway this will just be a frontend connected OLLAMA (local LLM platform) if you have it installed. You can save & load sessions from files.

I want this to have a focus on actually useful stuff like data organization & analysis so it will include built-in tools that make it much easier to do while attempting to prevent hallucinations by making many small requests.
