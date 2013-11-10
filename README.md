jekyll-liquid-latex-plugin
==========================

[Jekyll](http://Jekyllrb.com/) plugin that defines a useful Liquid Tag for rendering blocks of [LaTeX](http://en.wikipedia.org/wiki/LaTeX‎) code inside a post

Installation
============

Just copy the `liquid_latex.rb` to the `_plugins` folder.

Requirements
============

Obviously you must have a LaTeX installation of some kind (like [TeXLive](http://www.tug.org/texlive/)) and some additional software capable of transforming a EPS file to its corresponding PNG equivalent (like [ImageMagick](http://www.imagemagick.org/)).

Configuration
=============

There are several configuration parameters that you can define in your `_config.yml`. Here is a sample of such items:

    # ...
    # ... your _config.yml file ...
    # ...

    # Liquid-LaTeX plugin
    liquid_latex:
      debug: false
      density: 300
      usepackages: pst-all,pst-3dplot
      output_directory: /res/latex
      latex_cmd: "latex -interaction=nonstopmode $texfile &> /dev/null"
      dvips_cmd: "dvips -E $dvifile -o $epsfile &> /dev/null"
      convert_cmd: "convert -density $density $epsfile $pngfile &> /dev/null"
      temp_filename: "latex_temp"

An explanation of those parameters follows:

*   **`debug`** (`true`|`false`): Activates the debug mode with which you can see the compilation commands that are executed during build. Default value: `false`,

*   **`density`** (numeric): Density for the conversion of PostScript (EPS) to PNG. Default value:`300`,

*   **`usepackages`** (list of comma-separated strings): Name of the packages that will be passed globally to each block of LaTeX code. They will be added individually to their corresponding `\usepackage{...}` lines in the temporary $\LaTeX$ file. Default value: empty string (no packages),

*   **`output_directory`** (web path): Path in which the generated PNG will be placed. Default value: `/latex`,

*   **`temp_filename`** (string): Name of the temporary file that will be generated for the compilation process. Default value: "latex_temp"

*   **`latex_cmd`** (string): Command line to execute for the `.tex` to `.div` conversion. Default value:

        latex -interaction=nonstopmode $texfile &> /dev/null

*   **`dvips_cmd`** (string): Command line to execute for the `.dvi` to `.eps` conversion. Default value:

        dvips -E $dvifile -o $epsfile &> /dev/null

*   **`convert_cmd`** (string): Command line to execute for the `.eps` to `.png` conversion. Default value:

        convert -density $density $epsfile $pngfile &> /dev/null

In these last three parameters you can use the following variables:

*   **`$texfile`**: Name of the LaTeX temporary file
*   **`$dvifile`**: Name of the DVI temporary file
*   **`$epsfile`**: Name of the EPS temporary file
*   **`$pngfile`**: Name of the generated PNG file
*   **`$density`**: Density value that will be used by the conversion

This variables makes you able to choose which software you use for the whole conversion process. The sample shown above, as well as the default parameters, where defined for use with TeXLive and ImageMagick.

If your don't use a certain parameter, it will take the default value. If you are happy with all the default values you can omit the `liquid-latex` section in your `_config.xml`.

Sample usage
============

You can type the following block of LaTeX inside one of your posts:

{% latex density=72 usepackages=sudoku %}
\begin{sudoku}
| |2| | |3| |9| |7|.
| |1| | | | | | | |.
|4| |7| | | |2| |8|.
| | |5|2| | | |9| |.
| | | |1|8| |7| | |.
| |4| | | |3| | | |.
| | | | |6| | |7|1|.
| |7| | | | | | | |.
|9| |3| |2| |6| |5|.
\end{sudoku}
{% endlatex %}

And you will get that sudoku rendered by the `sudoku` package. Don't forget to install the `sudoku` package in your LaTeX installation before trying to build your site. If not, the build process will stop and you'll get the original LaTeX code inside your post as a block of code. That's how this plugin will behave when your LaTeX code contains errors.

In this case, you would probably need to install the `sudoku` package by executing:

    sudo tlmgr install sudoku

More information
================

