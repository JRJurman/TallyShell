TallyShell
==========

A configuration of IRB that allows for bash commands

Usage
-----

Copy .irbrc to your home directory and run irb

Notes
-----

Linux commands will be piped into bash (or whatever shell you have by default),
      however ruby evaluates right to left, so commands like "git rm file" will
      evaluate "rm file" first, so run "git 'rm file'".

TODO
----

-Clean up readme
-Add example usage
