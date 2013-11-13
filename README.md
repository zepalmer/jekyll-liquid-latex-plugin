jekyll-liquid-latex-plugin
==========================

[Jekyll](http://Jekyllrb.com/) plugin that defines a useful Liquid Tag for rendering blocks of [LaTeX](http://en.wikipedia.org/wiki/LaTeX‎) code inside a post

Installation
============

Just copy the `liquid_latex.rb` file to your `_plugins` folder.

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

*   `debug` (boolean): Activates the debug mode with which you can see the compilation commands that are executed during build. Default value: `false`
*   `density` (numeric): Density for the conversion of PostScript (EPS) to PNG. Default value:`300`
*   `usepackages` (list of comma-separated strings): Name of the packages that will be passed globally to each block of LaTeX code. They will be added individually to their corresponding `\usepackage{...}` lines in the temporary $\LaTeX$ file. Default value: empty string (no packages)
*   `output_directory` (web path): Path in which the generated PNG will be placed. Default value: `/latex`
*   `temp_filename` (string): Name of the temporary file that will be generated for the compilation process. Default value: `latex_temp`
*   `latex_cmd` (string): Command line to execute for the `.tex` to `.div` conversion. Default value: `latex -interaction=nonstopmode $texfile &> /dev/null`
*   `dvips_cmd` (string): Command line to execute for the `.dvi` to `.eps` conversion. Default value: `dvips -E $dvifile -o $epsfile &> /dev/null`
*   `convert_cmd` (string): Command line to execute for the `.eps` to `.png` conversion. Default value: `convert -density $density $epsfile $pngfile &> /dev/null`

In these last three parameters you can use the following variables:

*   `$texfile`: Name of the LaTeX temporary file
*   `$dvifile`: Name of the DVI temporary file
*   `$epsfile`: Name of the EPS temporary file
*   `$pngfile`: Name of the generated PNG file
*   `$density`: Density value that will be used by the conversion

This variables makes you able to choose which software you use for the whole conversion process. The sample shown above, as well as the default parameters, where defined for use with TeXLive and ImageMagick.

If your don't use a certain parameter, it will take the default value. If you are happy with all the default values you can omit the `liquid-latex` section in your `_config.xml`.

Usage
=====

The tag can be modified by the use of two parameters:

* `density` overrides the default density set in the `_config.yml` file or the internal default value. The value put here will take precedence.

* `usepackages` adds a list of packages to the ones set in the `_config.yml` file. This allows you to fix some common packages in the global configuration of the site and specify additional ones as you need them in each tag.

Both parameters must be specified in a `variable=value` style. For example:

{% raw %}
    {% latex density=100 usepackages=pst-all,pst-3dplot %}
    ...
    {% endlatex %}
{% endraw %}

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

And you will get that sudoku rendered by the `sudoku` package:

![Sample](sample.png)

If you copy this example, don't forget to install the `sudoku` package in your LaTeX installation before trying to build your site. If not, the build process will stop and you'll get the original LaTeX code inside your post as a block of code. That's how this plugin will behave when your LaTeX code contains errors and cannot be compiled.

In this case, you would probably need to install the `sudoku` package by executing:

    sudo tlmgr install sudoku

Notes
=====

*   The plugin doesn't recompile a previously rendered block of LaTeX. It takes into consideration a change in the text or a change in the arguments (density and packages used). This reduces the total time of the building process.

    Aside, you can delete all the contents of your LaTeX generated blocks in the source directory if you want to make a backup copy of your site. It will be completelly regenerated when you rebuild your site.

*   Also, this plugin keeps the folder of generated images in a clean state. That is, there will be only those images that are used in your site. All previously generated images will be deleted if they are detected as orphaned from the posts.

*   If you are trying to generate a picture with PSTricks, I recommend to insert the PSTricks code inside a TeXtoEPS environment. This ensures a perfect crop of the generated image.

For example:

{% raw %}
    {% latex density=72 usepackages=pst-all,pst-eps %}
    \begin{TeXtoEPS}
    \begin{pspicture}(0,0)(7,2)
    \psframe(0,0)(7,2) \psline(0,0)(7,2) \psline(7,0)(0,2)
    \end{pspicture}
    \end{TeXtoEPS}
    {% endlatex %}
{% endraw %}

More information
================

Take a look at my [http://www.flx.cat/jekyll/2013/11/10/liquid-latex-jekyll-plugin.html](http://www.flx.cat/jekyll/2013/11/10/liquid-latex-jekyll-plugin.html) blog entry!
