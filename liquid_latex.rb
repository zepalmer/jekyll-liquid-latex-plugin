require "digest"
require "fileutils"

module Jekyll
  module Tags
    class LatexBlock < Liquid::Block
      include Liquid::StandardFilters

      @@debugmode = false
      @@default_latex_density           = "300"
      @@default_latex_latex_cmd         = "latex -interaction=nonstopmode $1 &> /dev/null"
      @@default_latex_dvips_cmd         = "dvips -E $1 -o $2 &> /dev/null"
      @@default_latex_convert_cmd       = "convert -density 300 $1 $2 &> /dev/null"
      @@default_latex_output_directory  = "/latex"
      @@default_latex_temp_filename     = "latex_temp"

      @@generated_files = [ ]
      def self.generated_files
        @@generated_files
      end

      @@latex_http_dir = ""
      def self.latex_http_dir
        @@latex_http_dir
      end

      def initialize(tag_name, text, tokens)
        super
        
        # default values
        @options = { 
          "density" => @@default_latex_density, 
          "usepackages" => ""
        }
        
        # We now can adquire the options for this liquid tag
        text.gsub("  ", " ").split(" ").each do |part|
          if part.split("=").count != 2
            raise SyntaxError.new("Syntax Error in tag 'latex'")
          end
          var,val = part.split("=")
          @options[var] = val
        end
      end

      def self.read_config(site, param, default)
        resp = site.config[param]
        resp = default if resp.nil?
        return resp
      end

      def self.init_configs(site)
        # Get all the variables from the config and remember them for future use.
        if !defined?(@@first_time)
          @@first_time = true
          @@debug_mode = read_config(site, "latex_debug_mode", false)
          @@latex_cmd = read_config(site, "latex_latex_cmd", @@default_latex_latex_cmd)
          @@dvips_cmd = read_config(site, "latex_dvips_cmd", @@default_latex_dvips_cmd)
          @@convert_cmd = read_config(site, "latex_convert_cmd", @@default_latex_convert_cmd)
          @@latex_temp_filename = read_config(site, "latex_temp_filename", @@default_latex_temp_filename)
          @@latex_http_dir = read_config(site, "latex_output_directory", @@default_latex_output_directory)
          @@latex_source_dir = File.join(site.config["source"], @@latex_http_dir)
          @@latex_dest_dir = File.join(site.config["destination"] , @@latex_http_dir)
          # Verify and prepare the output folder if it doesn't exists
          FileUtils.mkdir_p(@@latex_source_dir) unless File.exists?(@@latex_source_dir)
        end
      end

      def render(context)
        latex = super

        site = context.registers[:site]
        Tags::LatexBlock::init_configs(site)

        # if this LaTeX code is already compiled, skip its compilation
        hash_txt = @options["density"] + @options["usepackages"] + latex;
        hash_txt = Digest::MD5.hexdigest(hash_txt)
        filename = hash_txt + ".png"
        filepath = File.join(@@latex_source_dir, filename)
        if !File.exists?(filepath)

          # Use the options from the tag
          density = @options["density"].to_i
          raise SyntaxError.new("Invalid density value in tag 'latex'") if density <= 0
          packages = ""
          @options["usepackages"].gsub(" ","").split(",").each do |packagename|
            packages << "\\usepackage\{#{packagename}\}\n"
          end

          # Put the LaTeX source code to a temporary file
          latex_tex = "
  \\documentclass[letterpaper,dvips]{article}
  \\usepackage{pst-all}
  \\usepackage{pst-3dplot}
  [:PACKAGES:]
  \\begin{document}
  \\pagestyle{empty}
  [:LATEX:]
  \\end{document}"

          latex_tex = latex_tex.gsub("[:PACKAGES:]", packages)
          latex_tex = latex_tex.gsub("[:LATEX:]", latex)
          tex_fn = @@latex_temp_filename + ".tex"
          dvi_fn = @@latex_temp_filename + ".dvi"
          eps_fn = @@latex_temp_filename + ".eps"
          tex_file = File.new(tex_fn, "w")
          tex_file.puts(latex_tex)
          tex_file.close

          # Compile the document to PNG
          cmd = @@latex_cmd.gsub("\$1", tex_fn)
          puts cmd if @@debug_mode
          system(cmd)
          raise SyntaxError.new("Error compiling with latex in tag 'latex'") if $?.exitstatus != 0
          cmd = @@dvips_cmd.gsub("\$1", dvi_fn).gsub("\$2", eps_fn)
          puts cmd if @@debug_mode
          system(cmd)
          raise SyntaxError.new("Error compiling with dvips in tag 'latex'") if $?.exitstatus != 0
          cmd = @@convert_cmd.gsub("\$1", eps_fn).gsub("\$2", filepath)
          puts cmd if @@debug_mode
          system(cmd)
          raise SyntaxError.new("Error compiling with convert in tag 'latex'") if $?.exitstatus != 0

          # Delete temporary files
          Dir.glob(@@latex_temp_filename + ".*").each { |f| File.delete(f) }

        end

        # Add the file to the list of static files for the final copy once generated
        st_file = Jekyll::StaticFile.new(site, site.source, @@latex_http_dir, filename)
        @@generated_files << st_file
        site.static_files << st_file

        # Build the <img> tag to return to the renderer
        outpath = File.join(@@latex_http_dir, filename)
        return "<img src=\"" + outpath + "\" />"
      end
    end
  end

  class Site
    alias :super_write :write

    def write
      super_write
      Tags::LatexBlock::init_configs(self)
      dest_folder = File.join(dest, Tags::LatexBlock::latex_http_dir)
      FileUtils.mkdir_p(dest_folder) unless File.exists?(dest_folder)

      # clean all previously rendered files not rendered in the actual build
      src_files = []
      Tags::LatexBlock::generated_files.each do |f|
        src_files << f.path
      end
      pre_files = Dir.glob(File.join(source, Tags::LatexBlock::latex_http_dir, "*"))
      to_remove = pre_files - src_files
      to_remove.each do |f|
        File.unlink f if File.exists?(f)
        d, fn = File.split(f)
        df = File.join(dest, Tags::LatexBlock::latex_http_dir, fn)
        File.unlink df if File.exists?(df)
      end
    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::Tags::LatexBlock)
