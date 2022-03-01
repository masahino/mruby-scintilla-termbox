MRuby::Gem::Specification.new('mruby-scintilla-termbox') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.add_dependency 'mruby-scintilla-base', :github => 'masahino/mruby-scintilla-base'
  spec.version = '5.2.1'

  def spec.download_scintilla
    require 'open-uri'
    scintilla_ver = '521'
    lexilla_ver = '515'
    scintilla_url = "https://scintilla.org/scintilla#{scintilla_ver}.tgz"
    scintilla_termbox_url = "https://github.com/masahino/scintilla-termbox"
    termbox_url = "https://github.com/nullgemm/termbox_next"
    lexilla_url = "https://scintilla.org/lexilla#{lexilla_ver}.tgz"
    scintilla_build_root = "#{build_dir}/scintilla/"
    scintilla_dir = "#{scintilla_build_root}/scintilla"
    scintilla_a = "#{scintilla_dir}/bin/scintilla.a"
    scintilla_termbox_dir = "#{scintilla_dir}/termbox"
    termbox_dir = "#{scintilla_termbox_dir}/termbox_next"
    lexilla_dir = "#{scintilla_build_root}/lexilla"
    lexilla_a = "#{lexilla_dir}/bin/liblexilla.a"
    scintilla_h = "#{scintilla_dir}/include/Scintilla.h"
    scintilla_termbox_h = "#{scintilla_termbox_dir}/ScintillaTermbox.h"
    lexilla_h = "#{lexilla_dir}/include/Lexilla.h"
    termbox_a = "#{termbox_dir}/bin/termbox.a"
    termbox_h = "#{termbox_dir}/src/termbox.h"

    file scintilla_h do
      URI.open(scintilla_url) do |http|
        scintilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write scintilla_tar
        end
      end
    end

    file scintilla_termbox_h => scintilla_h do
      Dir.chdir(scintilla_dir) do
        `git clone #{scintilla_termbox_url} termbox`
      end
    end

    file termbox_h => scintilla_termbox_h do
      Dir.chdir(scintilla_termbox_dir) do
        `git clone #{termbox_url}`
      end
    end

    file termbox_a => termbox_h do
      sh %((cd #{termbox_dir} && make CC=#{build.cc.command} AR=#{build.archiver.command}))
    end

    file scintilla_a => [scintilla_h, scintilla_termbox_h, termbox_a] do
      sh %((cd #{scintilla_termbox_dir} && make CXX=#{build.cxx.command} AR=#{build.archiver.command}))
    end

    file lexilla_h do
      URI.open(lexilla_url) do |http|
        lexilla_tar = http.read
        FileUtils.mkdir_p scintilla_build_root
        IO.popen("tar xfz - -C #{filename scintilla_build_root}", 'wb') do |f|
          f.write lexilla_tar
        end
      end
    end

    file lexilla_a => lexilla_h do
      sh %Q{(cd #{lexilla_dir}/src && make CXX=#{build.cxx.command} AR=#{build.archiver.command})}
    end

    task :mruby_scintilla_termbox_with_compile_option do
      linker.flags_before_libraries << scintilla_a
      linker.flags_before_libraries << lexilla_a

      linker.libraries << 'stdc++'
      [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |cc|
        cc.include_paths << "#{scintilla_dir}/include"
        cc.include_paths << "#{scintilla_dir}/src"
        cc.include_paths << scintilla_termbox_dir
        cc.include_paths << "#{lexilla_dir}/include"
      end
    end
    file "#{dir}/src/scintilla_termbox.c" => [:mruby_scintilla_termbox_with_compile_option, scintilla_a, lexilla_a]
    linker.flags_before_libraries << scintilla_a
    linker.flags_before_libraries << lexilla_a
    linker.flags_before_libraries << termbox_a

    linker.libraries << 'stdc++'
    [cc, cxx, objc, mruby.cc, mruby.cxx, mruby.objc].each do |cc|
      cc.include_paths << "#{scintilla_dir}/include"
      cc.include_paths << "#{scintilla_dir}/src"
      cc.include_paths << scintilla_termbox_dir
      cc.include_paths << "#{termbox_dir}/src"
      cc.include_paths << "#{lexilla_dir}/include"
    end
  end
end
