<!-- INFO {{{

# [/ael/data/documentation/word-frequency.md]
# author        : Pascal Malouin (https://github.com/alterEGO-Linux)
# created       : 2026-04-20 11:01:02 UTC
# updated       : 2026-04-20 11:01:02 UTC
# description   : word-frequency documentation.
# tags          : 

}}} -->

# word-frequency documentation

word-frequency is a simple and multi purpose utility, written in Python, to count the frequency of words in a text.

## Options

[**-i, --input INPUT**]\
Input file (if not provided, reads from stdin).

Analysing Moby Dick from stdin.

```shell
$ curl https://www.gutenberg.org/cache/epub/2701/pg2701.txt | word-frequency | head
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
100  1.21M 100  1.21M   0      0  1.45M      0                              0
the     14715
of      6746
and     6515
a       4799
to      4709
in      4241
that    3081
it      2535
his     2530
i       2120
```

As a provided files.

```shell
$ word-frequency --input moby-dick.txt | head
the     14715
of      6746
and     6515
a       4799
to      4709
in      4241
that    3081
it      2535
his     2530
i       2120
```

[**--case-sensitive**]\
Make word counting case-sensitive. The count will preserve the case sensitivity.

[**--sort {freq,alpha}**]\
Sort output by frequency or alphabetically. Default is frequency.

[**--significant**]\
Filter out common English stopwords. 

[**--stopwords STOPWORDS**]\
Path to stopwords file (can be used multiple times). Use custom stopwords files, one word per line.

[**--nocount**]\
Just gives the words, no count. Great to create a custom stopwords file.

<!--
# vim: foldmethod=marker
-->
