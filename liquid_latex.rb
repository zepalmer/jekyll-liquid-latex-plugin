# Original source of this file: https://github.com/fgalindo/jekyll-liquid-latex-plugin
# Modified to generate files in the same directory as the document containing the liquid tag

require "digest"
require "fileutils"

module Jekyll
  module Tags
    class LatexBlock < Liquid::Block
      include Liquid::StandardFilters

      @@globals = {
        "debug" => false,
        "density" => "300",
        "usepackages" => "",
        "latex_cmd" => "latex -interaction=nonstopmode $texfile > /dev/null 2>&1",
        "dvips_cmd" => "dvips -E $dvifile -o $epsfile > /dev/null 2>&1",
        "convert_cmd" => "convert -density $density $epsfile $pngfile > /dev/null 2>&1",
        "temp_filename" => "latex_temp",
      }

      @@generated_files = [ ]
      def self.generated_files
        @@generated_files
      end

      def initialize(tag_name, text, tokens)
        super
        # We now can adquire the options for this liquid tag
        @p = { "usepackages" => "" }
        text.gsub("  ", " ").split(" ").each do |part|
          if part.split("=").count != 2
            raise SyntaxError.new("Syntax Error in tag 'latex'")
          end
          var,val = part.split("=")
          @p[var] = val
        end
      end

      def self.read_config(name, site)
        cfg = site.config["liquid_latex"]
        return if cfg.nil?
        value = cfg[name]
        @@globals[name] = value if !value.nil?
      end

      def self.init_globals(site)
        # Get all the variables from the config and remember them for future use.
        if !defined?(@@first_time)
          @@first_time = true
          @@globals.keys.each do |k|
            read_config(k, site)
          end
        end
      end

      def execute_cmd(cmd)
        cmd = cmd.gsub("\$density", @p["density"].to_s)
        cmd = cmd.gsub("\$texfile", @p["tex_fn"])
        cmd = cmd.gsub("\$dvifile", @p["dvi_fn"])
        cmd = cmd.gsub("\$epsfile", @p["eps_fn"])
        cmd = cmd.gsub("\$pngfile", @p["png_fn"])
        puts cmd if @@globals["debug"]
        system(cmd)
        return ($?.exitstatus == 0)
      end

      def render(context)
        latex_source = super
        # fix initial configurations
        site = context.registers[:site]
        Tags::LatexBlock::init_globals(site)
        # prepare density and usepackages
        @p["density"] = @@globals["density"] unless @p.key?("density")
        @p["usepackages"] = (@@globals["usepackages"].split(",") + @p["usepackages"].split(",")).join(",")
        # if this LaTeX code is already compiled, skip its compilation
        hash_txt = @p["density"].to_s + @p["usepackages"].to_s + latex_source
        filename = "latex-" + Digest::MD5.hexdigest(hash_txt) + ".png"
        in_site_path = context.registers[:page]["dir"]
        dirname = File.join(site.source, in_site_path)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end
        @p["png_fn"] = File.join(dirname, filename)
        ok = true
        if !File.exists?(@p["png_fn"])
          puts "Compiling with LaTeX..." if @@globals["debug"]
          @p["tex_fn"] = @@globals["temp_filename"] + ".tex"
          @p["dvi_fn"] = @@globals["temp_filename"] + ".dvi"
          @p["eps_fn"] = @@globals["temp_filename"] + ".eps"

          # Put the LaTeX source code to file
          latex_tex = "\\documentclass[letterpaper,dvips]{article}\n"
          @p["usepackages"].gsub(" ","").split(",").each do |packagename|
            latex_tex << "\\usepackage\{#{packagename}\}\n"
          end
          latex_tex << "\\begin{document}\n\\pagestyle{empty}\n"
          latex_tex << latex_source
          latex_tex << "\\end{document}"
          tex_file = File.new(@p["tex_fn"], "w")
          tex_file.puts(latex_tex)
          tex_file.close
          # Compile the document to PNG
          ok = execute_cmd(@@globals["latex_cmd"])
          execute_cmd(@@globals["dvips_cmd"]) if ok
          execute_cmd(@@globals["convert_cmd"]) if ok
          # Delete temporary files
          Dir.glob(@@globals["temp_filename"] + ".*").each do |f|
            File.delete(f)
          end
        end

        if ok
          # Add the file to the list of static files for the final copy once generated
          st_file = Jekyll::StaticFile.new(site, site.source, in_site_path, filename)
          @@generated_files << st_file
          site.static_files << st_file
          # Build the <img> tag to be returned to the renderer
          return "<img src=\"" + filename + "\" />"
        else
          # Generate a block of text in the post with the original source
          resp = "Failed to render the following block of LaTeX:<br/>\n"
          resp << "<pre><code>" + latex_tex + "</code></pre>"
          return resp
        end
      end
    end
  end

  class Site
    # Alias for the parent Site::write method (ingenious static override)
    alias :super_latex_write :write

    def write
      super_latex_write   # call the super method
      Tags::LatexBlock::init_globals(self)

      # clean all previously rendered files not rendered in the actual build
      src_files = []
      Tags::LatexBlock::generated_files.each do |f|
        src_files << f.path
      end
      pre_files = Dir.glob(File.join(source, "**", "latex-*.png"))
      to_remove = pre_files - src_files
      to_remove.each do |f|
        File.unlink f if File.exists?(f)
      end
    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::Tags::LatexBlock)
