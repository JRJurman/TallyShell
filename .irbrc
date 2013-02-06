# .irbrc for TallyShell
# Created by Jesse Jurman

# Rubygems required to run properly
# This is a few gems from a much larger set of irbtools,
# for some functionality, others have been removed, 
# but it is well worth checking out!
require 'rubygems' unless defined? Gem # only needed in 1.8
require 'wirb'
require 'fancy_irb'
require 'colorize'

Wirb.start
FancyIrb.start
$ttyPrograms = ['vim', 'elinks', 'less', 
                'man', 'bash', 'zsh'] # programs that need the alias

prompt_dup = lambda do |s|
  def s.dup 
    gsub('%u', prompt_user).\
    gsub('%~', prompt_dir).\
    gsub('%gb', prompt_git_branch).\
    gsub('%gs', prompt_git_status).\
    gsub('%p', prompt_in)
  end
end

#   Define the custom prompt
#   .tap gives us a block for our object
#   and .dup lets us update it live
IRB.conf[:PROMPT][:TALLYSHELL] = {}
IRB.conf[:PROMPT][:TALLYSHELL] = {
  :PROMPT_I => "%u%~%gb%gs\n%p".tap { |s| prompt_dup.call(s) },  #   Normal Prompt
  :PROMPT_S => "%u%~%gb%gs\n * ".tap { |s| prompt_dup.call(s) }, #   Prompt for continuing strings
  :PROMPT_C => "%u%~%gb%gs\n * ".tap { |s| prompt_dup.call(s) }, #   Prompt for continuing statement
  :PROMPT_N => "%u%~%gb%gs\n * ".tap { |s| prompt_dup.call(s) }, #   Prompt for continuing function
  :RETURN => "==> %s\n"                               #   Prompt for return
}

#   Set IRB to use our custom prompt
IRB.conf[:PROMPT_MODE] = :TALLYSHELL

#   Define the ending characters for the prompt
#   also defines color for this item (colorize)
def prompt_in
  " > ".cyan
end

#   Display the current user logged in
#   also defines color for this item (colorize)
def prompt_user
  "[#{`whoami`.chomp}]".green
end

#   Display the current directory, "~" if $HOME
#   also defines color for this item (colorize)
def prompt_dir
  Dir.pwd!=`echo $HOME`.chomp ? "[#{Dir.pwd.split("/")[-1]}]".blue : "[~]".blue
end

#   Display the current git branch if in a git repo
#   also defines color for this item (colorize)
def prompt_git_branch
  if !is_git?
    return ""
  end
  stat = `git status`
  "[#{stat.split("\n")[0].split(" ")[-1]}]".yellow
end

#   Display characters based on git status if in a git repo
#   also defines color for this item (colorize)
def prompt_git_status
  if !is_git?
    return ""
  end
  stat = `git status`
  res = ""
  res += ( stat.include?("ahead") ? "^" : "" )
  res += ( stat.include?("modified") ? "*" : "" )
  res += ( stat.include?("untracked") ? "+" : "" )
  res += ( stat.include?("deleted") ? "-" : "" )
  res!="" ? "[#{res}]".magenta : ""
end

#   Check if the current repo is a git repo
#   Throws errors into null
def is_git?
  `git status 2> /dev/null` != ""
end

#   Check if the program is a bash command
#   Throws errors into null
def is_program?(p)
  programs = `ls /bin`.split("\n") + `ls /usr/bin`.split("\n")
  programs += ["cd"] # fun fact: cd is hard-coded into your shell
  programs.include?(p)
end

#   Alias for cd
def program_cd(*args)
  path = "#{args.join(" ")}"
  if path == ""
    path = Dir.home
  end
  Dir.chdir(path)
end

#   Alias for tty applications (elinks, vim, etc)
def program_tty(*args)
  puts args
  prog = args.join(" ")
  `#{prog} < \`tty\` > \`tty\``
end

#   Define Method Missing to handle bash commands
def self.method_missing(*args)

  # get the method (first argument) as a string
  method_id = [args[0]].join(" ")

  # check if the method_id is a bash program
  if !is_program?(method_id)

    # if not a program, return the arguments as a string
    return "#{args.join(" ")}"

  end

  # tell the user we are running a bash program
  #puts "> running #{method_id}".magenta

  # if it's cd, do our special implementation
  if method_id == "cd"
    program_cd(args[1..-1])

  # if it's a tty program, do our special implementation
  elsif $ttyPrograms.include?(method_id) 
    #puts "aliasing tty application"
    program_tty(args)

  # otherwise, do the system call, passing in any arguments
  else
    res = `#{method_id} #{args[1..-1].join(" ")}`
    puts res
    res

  end

end

#   Define Constant  Missing to handle uppercase words 
class Object
def self.const_missing(name)
  name
end
end
