# surfer.vim

This plugin provides a nice interface for searching and navigating tags.

![Screenshot](_assets/screenshot.png "Surfer in action.")


## Installation

### 1. Check the requirements

Surfer requires Vim 7.3+ compiled with Python 2.x support (2.6+).

Surfer requires Exuberant Ctags in order to generate tags but if you don't have
it installed yet this can be easily fixed. Go ahead and read the **Step 2**.

### 2. Install Ctags

This first step is required only if you want Surfer to generate tags by himself
(see the option `g:surfer_generate_tags` further in the documentation). If want
to rely on a third party tags generator you can safely jump ahead to *Step 3*.

First, you need to get [Exuberant Ctags](http://ctags.sourceforge.net/). You can
check if it is already installed on your system with `$ ctags --version`.

* **Windows**: You can easily get the `ctags.exe` executable from the
  [Ctags](http://ctags.sourceforge.net) site. Download and extract `ctags.exe`
  in a folder within your `%PATH%`.

* **OS X**: Unfortunately, the *Ctags* program that you may find under `/usr/bin`
  is outdated, so you need to get a more recent version of Ctags. The easiest
  way to do this is with *homebrew*: `$ brew install ctags`.

* **Debian, Ubuntu, Mint, etc**: Execute `$ sudo apt-get install exuberant-ctags`.

* **Red Hat, Fedora, CentOS, etc**: Execute `$ sudo yum install ctags`.

### 3. Install Surfer

Install the plugin with [Vundle](https://github.com/gmarik/vundle)

```vim
" this line needs to be added to your .vimrc file
Bundle "gcmt/surfer.vim"
```

or [Pathogen](https://github.com/tpope/vim-pathogen)

```shell
$ cd ~/.vim/bundle
$ git clone git://github.com/gcmt/surfer.vim.git
```

### Troubleshooting

Usually *Surfer* is able to locate the correct *Ctags* program by himself,
otherwise add the following line in your `.vimrc`:
```vim
let g:surfer_ctags_prg = "/path/to/ctags"
```

## Basic usage

To open *Surfer* execute the `:Surf` command. As you type something, Surfer will
show you a list of tags in the current session that match your query. You can
interact with search results with the following keys.

* `UP`, `TAB`, `CTRL+K`: move up.
* `DOWN`, `CTRL+J`: move down.
* `RETURN`, `CTRL+O`, `CTRL+G`: jump to the selected tag.
* `CTRL+P`: open a preview window for the selected tag.
* `CTRL+S`: split the window for the selected tag.
* `ESC`, `CTRL+C`: close *Surfer*.
* `CTRL+U`: clear the current search.

Rememberer that when you jump to a tag you can easily jump back to the previous
position with `CTRL+T`, as you would normally do in Vim.

### Filters

Searches are not limited to the current session. In fact, you can filter tags
prepending special characters to the search query. By default some filters are
defined for you:

* ` `: this is the empty modifier. This modifier narrows the search scope to
only open buffers.
* `%`: this modifier narrows the search scope to the current buffer.
* `#`: this modifier widens the search scope to all files of the current project.
Note that a project root is assumed to be the one that contains any of the file
or directory names listed in `g:surfer_root_markers`.

These are the special characters that Surfer provides by default but you are not
limited in the number of modifiers that you can create. See the option
`g:surfer_filters` and the [advanced usage](https://github.com/gcmt/surfer.vim#advanced-usage)
section for more information.

## Basic options

### g:surfer\_ctags\_prg

With this option you can set the path of the Ctags executable on your system.
You usually need to do this only if Surfer is not able to locate the Ctags
executable by himself.

Default: `""`

### g:surfer\_smart\_case

This option controls the way matching works. When this option is turned on,
a search is case-insensitive only if you enter the search string in all lower
case letters.

Default: `1`

### g:surfer\_exclude\_tags

With this option you can set a list of glob-style patterns used to exclude tags
according to their name.

**NOTE**: This option is respected only when default modifiers are used (See
[Advanced usage](https://github.com/gcmt/surfer.vim#advanced-usage) and `g:surfer_filters`)

Example:
```vim
let g:surfer_exclude_tags = ["test_*", "__init__"]
```

Default: `[]`

### g:surfer\_exclude\_kinds

With this option you can set a list of kind to be excluded. To get a list of the
kinds that Ctags is able to recognize per language, execute the command `$ ctags
--list-kinds`.

**NOTE**: This option is respected only when default modifiers are used (See
[Advanced usage](https://github.com/gcmt/surfer.vim#advanced-usage) and `g:surfer_filters`)

Example:
```vim
let g:surfer_exclude_kinds = ["namespace", "package"]
```

Default: `[]`

### g:surfer\_root\_markers

With this option you can set file and directory names that are used to locate
the root of the current project.

Note that when you assign a list to this option the default markers are extended,
not replaced.

Default: `['.git', '.svn', '.hg', '.bzr']`

### g:surfer\_generate\_tags

Turn this option on to let Surfer generate tags for you when necessary,
otherwise turn this option off.

Read the section [Advanced usage](https://github.com/gcmt/surfer.vim#advanced-usage)
for more information.

Default: `1`

### g:surfer\_filters

With this option you can set up filters. Filters limit the search scope to a set
of tags that meet certain conditions and are triggered by prepending the
search query with a special character. If you look at
the default value for this option, you can see where the default *filters* encountered
[before](https://github.com/gcmt/surfer.vim#basic-usage) come from. As you can
see, to each character is assigned a function name. This is the (python) function
used to filter each tag according to some rules. These functions must be defined
somewhere in your `.vimrc` and must conform to a specific format.

The default functions are defined by Surfer and their meaning is pretty clear.
* `SurferSessionFilter`: filter search results to all tags defined in all open buffers.
* `SurferBufferFilter`: filter search results to tags defined in the current buffer only.
* `SurferProjectFilter`: filter search results to all tags defined in the current project.

Read the [Advanced usage](https://github.com/gcmt/surfer.vim#advanced-usage)
section for examples about how to define your own filter functions.

**NOTE**: The modifier `" "` is not a real modifier. We use it just as
convenienet character to indicate the functions to be called when no modifier is
prepended to the search query.

Default: `{" ": "Surfer#SessionFilter", "#": "SurferProjectFilter", "%": "SurferBufferFilter"}`

## Appearance

### How to set colors

This little section explains how to set color values in *dictionary options*
listed below that accepts colors. Let's start having a look at three examples:

```vim
" example 1
let g:surfer_prompt = {
    \ "color": "String",
}

" example 2
let g:surfer_curr_line_indicator = {
    \ "color": "guifg=#FF00FF ctermfg=#FF00FF",
    \ "color_darkbg": ""
}
```

Below a list of what you can learn from the examples above:

* If you set only the value for the key `color` (as the first example does) this will
  be used for both light and dark backgrounds.

* To set colors for *light* and *dark* backgrounds separately, use respectively
  the dictionary keys `color` and `color_darkbg`.

* As color values you can use either a predefined highlight groups (`:h
  highligh-groups`) or complete color definitions (as you can see in the second
  example.

* To use the default *foreground* color of your color scheme, you can simply omit
  to set colors or set an empty string as color value.

### g:surfer\_max\_results

This option controls the maximum number of search results displayed.

Default: `15`

### g:surfer\_line\_format

This options controls the format of search results. This option is a list of
strings and each one can contain at most one special *placeholder* that will be
later substituted with the corresponding value. When the value for a placeholder
is absent, the whole list item won't be displayed. Available placeholders vary
across different languages but common placeholders include:

* `{file}`: the file in which the tag is defined.
* `{line}`: the line of the tag in `{file}`.
* `{kind}`: the kind of the tag.
* `{class}`: the name of the class for which the tag is a member or method.
* `{language}`: the language of the file in which tags is defined.

Example:

```vim
let g:surfer_line_format = [" @ {file}", " ({line})", " {kind}"]
```

Default: `[" @ {file}"]`

### g:surfer\_tag\_file\_custom\_depth

This option affects how the value for the placeholder `{file}` in `g:surfer_line_format`
is formatted. If the value is greater than zero, the value represent the maximum
number of container directories displayed in the file path.

Default: `-1`

### g:surfer\_tag\_file\_relative\_to\_project\_root

When this option is turned on and a project root exists (see `g:surfer_root_markers`),
the value of the placeholder `{file}` in `g:surfer_line_format` is displayed
relative to the project root.

**NOTE**: This option override the option `g:surfer_tag_file_custom_depth` when
the project root is found.

Default: `1`

### g:surfer\_prompt

This option controls how the *Surfer* prompt looks.

This is option is a dictionary and looking at the default value will give you an
hint about how to set this option. Note that when you assign something to this
option you just have to assign a dictionary with only the values for what you want
to change.

Read [How to set colors](https://github.com/gcmt/surfer.vim#how-to-set-colors)
to learn how to set colors.

Default: `{"appearance": "@ ", "color": "", "color_darkbg": ""}`

### g:surfer\_current\_line\_indicator

This option controls how the current line indicator looks.

This is option is a dictionary and looking at the default value will give you an
hint about how to set this option. Note that when you assign something to this
option you just have to assign a dictionary with only the values for what you want
to change.

Read [How to set colors](https://github.com/gcmt/surfer.vim#how-to-set-colors)
to learn how to set colors.

Default: `{"appearance": " ", "color": "", "color_darkbg": ""}`

### g:surfer\_shade

This option controls how tags information (except the tag name) looks.

This is option is a dictionary and looking at the default value will give you an
hint about how to set this option. Note that when you assign something to this
option you just have to assign a dictionary with only the values for what you want
to change.

Read [How to set colors](https://github.com/gcmt/surfer.vim#how-to-set-colors)
to learn how to set colors.

Default: `{"color": "Comment", "color_darkbg": ""}`

### g:surfer\_matches

This option controls how matches look.

This is option is a dictionary and looking at the default value will give you an
hint about how to set this option. Note that when you assign something to this
option you just have to assign a dictionary with only the values for what you want
to change.

See [How to set colors](https://github.com/gcmt/surfer.vim#how-to-set-colors)
to learn how to set colors.

Default: `{"color": "WarningMsg", "color_darkbg": ""}`

### g:surfer\_visual\_kinds

This option controls whether or not visual kinds appear and how they look.
A visual kind is simply a colored visual representation of tag kinds.

This is option is a dictionary and looking at the default value will give you an
hint about how to set this option. Note that when you assign something to this
option you just have to assign a dictionary with only the values for what you want
to change.

Default: `{"active": 0, "appearance": "\u2022 "}`

### g:surfer\_visual\_kinds.colors

This is not a standalone option but for simplicity it has been presented separately.

With this option you can customize the color of `g:surfer_visual_kinds.appearance`
for each kind. (To get a list of all kinds recognized by Ctags execute `$ctags --list-kinds`).
Remember to use a dictionary with just the kinds you want to add or change when
you assign a dictionary to this option.

Read [How to set colors](https://github.com/gcmt/surfer.vim#how-to-set-colors)
to learn what values can be used as colors.

Default:

```vim
{
    "interface": "Repeat", "class": "Repeat",
    "member": "Function", "method": "Function", "function": "Function",
    "type": "Type", "struct": "Type",
    "variable": "Conditional", "constant": "Conditional",
    "field": "String", "property": "String",
    "namespace": "Constant", "package": "Constant",
}
```

### g:surfer\_visual\_kinds.colors\_darkbg

Same as `g:surfer_visual_kinds.colors` but for dark backgrounds.

Default: `<the value of g:surfer_visual_kinds.colors>`

## Advanced usage

### Languages support

Exuberant Ctags only supports a limited set of languages (`$ ctags --list-languages`).
If you need support for a new language you can rely on extending capabilities
provided by Ctags itself that requires you to add some lines to the file
`$HOME/.ctags`. If you search the web you'll certainly find out some prepackaged
solutions suitable for your favorite language.

Check this [link](http://ctags.sourceforge.net/EXTENDING.html) to learn how to
integrate custom languages in Exuberant Ctags.

### How to use Surfer with a third party tags generator

If you happen to use a third party tags generator you certainly don't want
Surfer to generate tags for you. This can be achieved turning off the
`g:surfer_generate_tags` options. In fact, when this option is turned off,
Surfer acts as a simple interface for searching tags that can be found through
the vim option `&tags` (see `:h 'tags'` and `:h tagfiles()`). This means that
is your responsibility to ensure that the `&tags` option is kept updated.

However, you should be aware of few things when this option is turned off:

* To ensure that Surfer can handle duplicate tags as expected you need to let
  him know the line number where tags are defined. This can be achieved using
  the parameter `--excmd=number` when executing the `ctags` program.

* If you are using visual kinds, be sure that kinds generated by the external
  tag generator match the kinds in `g:surfer_visual_kinds.colors` so that they
  are colored properly. You can use the parameter `--fields=+K` to have full-name
  kinds instead of single-letter kinds (which is the default behavior of `ctags`).

You can read about further customizations that can be useful when tag generation
is turned off in the [next section](https://github.com/gcmt/surfer.vim#how-to-customize-modifiers).

### How to create filters

With the option `g:surfer_filters` you can completely customize how Surfer
behaves. Creating filters is a way to limit the search scope to only those tags
who meet certain conditions so that the clutter is removed from search results,
especially in large projects, and you can better find what you're searching for.

To better understand how this option works, let's have a look at its default value:

```
{
    " ": "Surfer#SessionFilter",
    "#": "SurferProjectFilter",
    "%": "SurferBufferFilter"
}
```

As you can see, this option is a dictionary whose keys are characters (`" "`,
`"#"`, `"%"`) and whose values are names of predefined python functions (in this
case `SurferSessionFiles`, `SurferProjectFilter` and `SurferBufferFilter`, that
are functions defined by Surfer). When any of the characters listed is prepended
to a search query, the respective function is used to filter tags before search
is performed.

Note that the character `" "` (the space character) can be considered as a kind
of exception since it is triggered whenever no modifier is prepended to the
search query.

**How to define your own filter functions**

This section is better explained by having a look at an example:

```vim
" this is your .vimrc

let g:surfer_filters = {"&": "TestsFilter"}

...
```

As you can see, filter function must be written in Python (`:h python`) and must
be defined in your `.virmc`.

First, to create a filter we have to assign to `g:surfer_filters` a new
dictionary containing the character we will use to trigger the filter (`&`) and
the function used to filter tags (`TestsFilters`). Note that default filters are
not replaced. To replace them you must override the characters `" "`, `"%"` and
`"#"`.

Then we need to define the function that will be used to filter tags.

```vim
" this is your .vimrc

let g:surfer_filters = {"&": "TestsFilter"}

python << END

def TestsFilter(tags, project_root, curr_buffer, open_buffers):
    from fnmatch import fnmatch
    for tag in tags:
        if any(fnmatch(tag["name"], patt) for patt in ["Test*"]):
            yield tag

END
```

The function `TestsFilter` will be called to filter tags before searching for
the given search query.

As you can see from the example above, this function will be called with a fixed set of
arguments:

* `tags`: this is a list containing all tags for the current project (see
  `g:surfer_root_markers`) or, if a project root cannot be found, tags defined
  in all open buffers). A single `tag` is a dictionary containing all
  information for the tag. Below is the structure of the dictionary representing
  the tag (Note that he dictionary may contain different information if it is
  not Surfer the one responsible for generating tags):
    ```vim
    {
        "name": < the tag name >
        "file": < the file where the tag is defined >
        "exts": {
            "kind": < the kind of the tag >
            "language": < the language of the tag >
            "line": < the line number where the tag is defined >
            ...
            }
    }
    ```

* `project_root`: this is a string whose value is the current project root (see
  `g:surfer_root_markers`). If a project root cannot be found, this is an empty
  string.

* `curr_buffer`: this is a string whose value is the path of the current buffer.

* `open_buffers`: this is a  list containing all listed buffers.

**NOTE** All strings passed to the function are unicode strings, so be aware of
that when performing string comparison.


## Contributing

Do not hesitate to send [patches](../../issues?labels=bug&state=open),
[suggestion](../../issues?labels=enhancement&state=open) or just to ask
[questions](../../issues?labels=question&state=open)! There is always room for improvement.

## Credits

See [this page](https://github.com/gcmt/vim-surfer/graphs/contributors) for all *Surfer* contributors.
