#!/usr/bin/env julia

# Author: Anand S Bisen <Anand.Bisen@SAS.COM>
# Description
#
# The script compiles Python 3.7+ from source to a self contained directory. 
# Optionally it also installs python packages specified in `requirements.txt`
#
# Usage: build-python.jl -v <python3-version> -d <destination-directory> -r <path-to-requirements.txt>


using ArgParse
import Downloads: download


struct Arguments
        uri::AbstractString
        version::AbstractString
        requirements::Union{Nothing, AbstractString}
        destination::AbstractString
end

function Arguments(version::AbstractString, 
                   requirements::Union{Nothing, AbstractString},
                   destination::AbstractString
                   )

        uri="https://www.python.org/ftp/python/$(version)/Python-$(version).tgz"
        Arguments(uri, version, requirements, destination)
end

filename(o::Arguments)=basename(o.uri)
basefilename(o::Arguments)=splitext(filename(o))[1]


function parsecmd()
        s = ArgParseSettings()
        @add_arg_table! s begin

                "--version", "-v"
                help = "python version"
                arg_type = String
                default = "3.9.6"

                "--requirements", "-r"
                help = "path to requirements.txt file"
                arg_type = String

                "--build-dir", "-d"
                help = "build directory"
                arg_type = String
                default = "/python"

        end

        r=parse_args(s)
        return Arguments(r["version"], abspath(r["requirements"]), r["build-dir"])
end


function download_python(o::Arguments)
        outpath = joinpath("/tmp", filename(o))

	@info("Downloading Python $(o.uri)")
	try
		res = download(o.uri, outpath, verbose=false)
	catch e
		@error("Error downloading $(o.uri)")
	end
end


function extract_python(o::Arguments)
	@info("Extracting Python to /tmp/$(basefilename(o))")
        cmd=`tar -zxvf /tmp/$(filename(o)) -C /tmp`
        ret=run(cmd)
end


function build_python(o::Arguments)
        cd("/tmp/$(basefilename(o))")

        # Configure
        cmd=`./configure --enable-optimizations --prefix=$(o.destination)`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("configure failed $(cmd)")
        end

        # build
        cmd=`make -j2`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("make failed $(cmd)")
        end

        # install
        cmd=`make install`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("make failed $(cmd)")
        end

end


function configure_pip(o::Arguments)
        cd("$(o.destination)")

        cmd=`bin/pip3 install --upgrade pip`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("make failed $(cmd)")
        end


        cmd=`bin/pip3 install wheel`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("make failed $(cmd)")
        end

end


function install_packages(o::Arguments)
        cd("$(o.destination)")

        cmd=`bin/pip3 install swat saspy`
        @info("Executing $(cmd)")
        r=run(cmd)
        if r.exitcode != 0
                println("Exit Code: $(r.exitcode)")
                println("Error: $(r.err)")
                @error("pip3 failed $(cmd)")
        end

        if o.requirements !== nothing
                cmd=`bin/pip3 install -r $(o.requirements)`
                @info("Executing $(cmd)")
                r=run(cmd)
                if r.exitcode != 0
                        println("Exit Code: $(r.exitcode)")
                        println("Error: $(r.err)")
                        @error("pip3 failed $(cmd)")
                end
        end

end


function main()
        r = parsecmd()

        download_python(r)
        extract_python(r)
        build_python(r)
        configure_pip(r)
        install_packages(r)
        
end

main()
