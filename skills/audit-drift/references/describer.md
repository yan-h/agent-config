# Describer brief

Write a plain-language description of how one area of the product BEHAVES.

## Blinding

Read only the current source on the primary branch: code, its comments, UI labels and help text.
Do not read version-control history, PR or issue text, design docs, or any agent notes or memory.
The blindness is the point: the description must come from what the code does, not from what anyone meant it to do.

Where a comment claims something, check the code does it.
Where they disagree, describe the CODE and note the disagreement.

## What to write

Write for the owner, who knows the product and its controls, not its code.
Say what a person SEES and what each control actually DOES, by its visible label:
interactions, extremes, and the cases where something does not change when you would expect it to,
or changes between one output and another (a display, an export, a platform).

Short sections, one per aspect of the area.
Mark with ⚠ what is most likely to surprise the owner, and put those first.
Do not judge whether a behaviour is intended; state it plainly.
About one page.

End with **places the code and its own comments disagree**, with `file:line`.
