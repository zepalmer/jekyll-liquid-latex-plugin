jekyll-liquid-latex-plugin
==========================

Jekyll plugin that defines a useful Liquid Tag for rendering blocks of LaTeX code inside a post

Installation
============

Just copy the `liquid_latex.rb` to the `_plugins` folder.

Configuration
=============

There are several configuration parameters that you can define in your `_config.yml`. Here is a sample of such items:

    # ...
    # ... your _config.yml file ...
    # ...

    # Liquid-LaTeX plugin
    latex_debug_mode: false
    latex_density: 300
    latex_output_directory: /res/latex
    latex_latex_cmd: "latex -interaction=nonstopmode $1 &> /dev/null"
    latex_dvips_cmd: "dvips -E $1 -o $2 &> /dev/null"
    latex_convert_cmd: "convert -density 300 $1 $2 &> /dev/null"
    latex_temp_filename: "latex_temp"

