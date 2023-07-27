:command! -nargs=0 Lint :call Lint()
function Lint() 
   let result = system('lint ' . @%)
   echo result
endfunction

:command! -nargs=0 Doko :call Doko()
function Doko() 
    execute ":! doko " . expand("<cWORD>") 
endfunction

:command! -nargs=0 Strings :call Strings()
function Strings() 
   let assfile = @% . ".strings"
   let result = system('strings ' . @% . ' >> ' . assfile)
   exe 'edit ' . assfile
endfunction

function! s:get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

nnoremap <C-h> :Goto<CR>
:command! -nargs=? Goto :call Goto()

command! DockerIn call DockerIn()
function! DockerIn()
   execute ":! docker exec -it sc-app bash"
endfunction

command! Routes call Routes()
function! Routes()
   execute ":! docker exec -it sc-app bundle exec annotate --routes"
endfunction

function! GetRootDir(filename)
  let rootdir = fnamemodify(findfile(a:filename), ':p:h')
  return rootdir
endfunction

:command! -nargs=? Imitate :call Imitate(<f-args>)
function! Imitate(...)
  if a:0 >=1
    let old_file_path = @%
    let rootdir = GetRootDir(old_file_path)    
    let new_file_path = rootdir . "/" . a:1
    execute ":! cp " . old_file_path . " " . new_file_path
    execute "edit " . new_file_path
  else
    echo "you need argument"
  endif
endfunction

command! Rubocop call Rubocop()
function! Rubocop()
   execute ":! docker exec -it sc-app bundle exec rubocop -A"
endfunction

nnoremap T :Test<CR>
command! Test call Test()
function! Test()
   execute ":! docker exec -it sc-app bundle exec rspec " . @% 
endfunction

function! Goto()
    let word = expand("<cword>")
    execute ':Ag ' . word
endfunction

command! Blame call Blame()
function! Blame()
    let file   = @%
    let linenum = line(".")
    let command = "git blame -L " . linenum . "," . linenum . " " . file
    let result = system(command)
    echo result
endfunction

:command! -nargs=? Trans :call Trans(<f-args>)
function Trans(...) 
  if a:0 >=1
    let result = system(g:script_dir . "18 " . a:1)
  else
    let result = system(g:script_dir . "18 " . expand("<cword>"))
  endif
  echo result
endfunction

:command! -nargs=? Toenglish :call Toenglish(<f-args>)
function Toenglish(...) 
  if a:0 >=1
    let result = system("translate -s ja -t en " . a:1)
  else
    let line = getline(".")
    let result = system("translate -s ja -t en " . line)
  endif    
  put =result
endfunction

:command! -nargs=? Tocamelenglish :call Tocamelenglish(<f-args>)
function Tocamelenglish(...) 
  if a:0 >=1
    let result = system("translate -s ja -t en " . a:1 . "| sed \"s/'//g\" | xs tocamel")
  else
    let line = getline(".")
    let result = system("translate -s ja -t en " . line . "| sed \"s/'//g\" | xs tocamel")
  endif    
  put =result
endfunction

:command! -nargs=? Bash :call Bash(<f-args>)
function Bash(...) 
  if a:0 >=1
    "echo a:000  
    let result = system("" . a:1)
  else
     let result = system("ls")
  endif
  echo result
endfunction

map q <Nop>

:command! -nargs=1 Rename :call Rename(<f-args>)
function Rename(...) 
   if a:0 >=1
       let root    = system("pwd")
       let file_path = root . '/' . @%
       let dirname = system("dirname " . @%)
       let new_file_path = root . '/' . dirname . "/" . a:1
       let cmd = substitute("mv " . file_path . ' ' . new_file_path, '\n', '', 'g')
       let result = system(cmd)
       let dirname_1 = substitute(dirname, '\n', '', 'g') 
       exe 'edit ' . dirname_1 . "/" . a:1
   else
   endif
endfunction

:command! -nargs=0 Branchprint :call Branchprint()
function Branchprint() 
   let result = system('git rev-parse --abbrev-ref HEAD')[:-2] . ' '
   put =result
endfunction

:command! -nargs=0 Nm :call Nm()
function Nm() 
   let assfile = @% . ".nm"
   let result = system('nm ' . @% . ' >> ' . assfile)
   exe 'edit ' . assfile
endfunction

:command! -nargs=0 Otool :call Otool()
function Otool() 
   let assfile = @% . ".asm"
   let result = system('otool -tvVI ' . @% . ' >> ' . assfile)
   exe 'edit ' . assfile
endfunction

if &compatible
  set nocompatible
endif
filetype plugin indent on

:inoremap <S-Tab> <C-V><Tab>

:command! -nargs=0 Tasja :call Tasja()
function! Tasja()
    let result = system("tasja")
    echo 'coppied to the clipboard'
endfunction


function! Repeat()
    let times = input("Count: ")
    let char  = input("Char: ")
    exe ":normal a" . repeat(char, times)
endfunction

"inoremap <C-c> <Esc> 

"
" better experience in VIM insert mode
"
inoremap <C-b> <Left>
inoremap <C-f> <Right>
" inoremap <C-j> <Down>
" inoremap <C-k> <Up>


nnoremap い i 
nnoremap お o
nnoremap O O

nnoremap <C-x><C-f> :e
nnoremap C :!
nnoremap <Down>  :res -5<CR>
nnoremap <Up>    :res +5<CR>
nnoremap <Left>  :vertical res -5<CR>
nnoremap <Right> :vertical res +5<CR>

imap <C-u> <C-o>:call Repeat()<cr>
set path+=**
set mouse=
set noswapfile
set hidden
set ma
" let g:ag_prg="/usr/local/bin/ag --vimgrep"
let g:ag_prg="/opt/homebrew/bin/ag --vimgrep"

let g:ag_working_path_mode="r"
nnoremap s :w<CR>
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set statusline=\PATH:\ %r%F\ \ \ \ \LINE:\ %l/%L/%P\ TIME:\ %{strftime('%c')}
set nowrapscan
set tags=./tags;$HOME
filetype off

"
" Package managers
"
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
"Plugin 'tpope/vim-fugitive'
Plugin 'preservim/nerdtree'
"Plugin 'vim-airline/vim-airline'
"Plugin 'vim-airline/vim-airline-themes'
call vundle#end()

"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline_theme='soda'

"nnoremap <C-s> :NERDTreeToggle<CR>
nnoremap } :NERDTreeToggle<CR>
let g:NERDTreeNodeDelimiter = "\u00a0"

nnoremap Q :b **/*
nnoremap * :Randopen<CR>
nnoremap ( :Ranexs<CR>
nnoremap ) :Ranobj<CR>
nnoremap <C-n> 5j
nnoremap <C-p> 5k
vnoremap <C-n> 5j
vnoremap <C-p> 5k
vnoremap <C-y> "*y 
nnoremap x "_x
tnoremap <C-z> exit<cr>
nnoremap s "_s
nnoremap tt :tabnew<cr>
nnoremap tn gt
nnoremap tp gT
nnoremap tw :windo bd<cr>
xnoremap <expr> p 'pgv"'.v:register.'y`>'
inoremap <C-d> <Del>
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
nmap # <Space><Space>:%s/<C-r>///g<Left><Left>
xnoremap <silent> <Space> mz:call <SID>set_vsearch()<CR>:set hlsearch<CR>`z
xnoremap * :<C-u>call <SID>set_vsearch()<CR>/<C-r>/<CR>
xmap # <Space>:%s/<C-r>///g<Left><Left>
 
:command! -nargs=0 Comit :call Comit()
function! Comit()
  let branch = substitute(system("git rev-parse --abbrev-ref HEAD"), '\n', '', 'g')
  let result = branch . ' #comment fix: xxx' 
  put =result
endfunction

:command! -nargs=0 Dare :call Dare()
function! Dare()
  let result = system(g:script_dir . "blamer " . @% . " " . line("."))
  echo result
endfunction

:command! -nargs=? Show :call TimeMachine(<f-args>)
function! TimeMachine(...)
  if a:0 >=1
    let result = system("git show " . a:1 . ":" . @%)
    put =result
  else
     let result = system("git branch")
     echo result
  endif
endfunction

:command! -nargs=0 Copyall :call Copyall()
function! Copyall()
     let result = system("cat " . @% . " | pbcopy")
endfunction

function! s:set_vsearch()
  silent normal gv"zy
  let @/ = '\V' . substitute(escape(@z, '/\'), '\n', '\\n', 'g')
endfunction
set number


"inoremap <C-p> <Up>
"inoremap <C-n> <Down>
"inoremap <C-f> <Right>
"inoremap <C-b> <Left>

"
" Say fuck No to the ten key
"
nnoremap <C-z> :q!<CR>
"nnoremap <Up> :echo "No up for you!"<CR>
"vnoremap <Up> :<C-u>echo "No up for you!"<CR>
"inoremap <Up> <C-o>:echo "No up for you!"<CR>
"nnoremap <Down> :echo "No down for you!"<CR>
"vnoremap <Down> :<C-u>echo "No down for you!"<CR>
"inoremap <Down> <C-o>:echo "No down for you!"<CR>
"nnoremap <Left> :echo "No left for you!"<CR>
"vnoremap <Left> :<C-u>echo "No left for you!"<CR>
"inoremap <Left> <C-o>:echo "No left for you!"<CR>
""nnoremap <Right> :echo "No right for you!"<CR>
"vnoremap <Right> :<C-u>echo "No right for you!"<CR>
"inoremap <Right> <C-o>:echo "No right for you!"<CR>

"
"  powerful search
"
nnoremap S :e **/
"nnoremap S :find  

"
"  yank and paste
"
"nnoremap <Right> "*yy

"set langmenu=en_US
"let $LANG = 'en_US'


"
" terminal
"
tnoremap <C-s> :<C-w>N
nnoremap <C-x>m :res +5<CR>
nnoremap <C-x>, :res -5<CR>
nnoremap <C-t> :bot term ++close ++rows=25<CR>
nnoremap <C-x>v :vert term ++close<CR>

command Standup :! echo '-----------------------------------------';cat /wiki/.taskupdate; echo '------------------------------------------'
command Dirty syntax on
command CDC cd %:p:h

"
" toggler
"
nnoremap <C-x>j :n<CR>
nnoremap <C-x>k :N<CR>

  
set hlsearch
hi Search ctermbg=LightYellow
hi Search ctermfg=DarkRed
set noautoindent
set smartindent
set runtimepath+=~/.vim/bundle/neobundle.vim/
"  
"  syntax keyword WordError teh
"  
"when vimgrep/grep
" nnoremap <C-j> :cn<CR>
" nnoremap <C-k> :cN<CR>

nnoremap <C-,> :Trans<CR>

"  
"  if 0 | endif
"  if &compatible
"    set nocompatible               " Be iMproved
"  endif
"  
call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'rking/ag.vim'

call neobundle#end()
"  
"  map <c-q> :call JsBeautify()<cr>
"  autocmd FileType javascript noremap <buffer> <c-q> :call JsBeautify()<cr>
"  autocmd FileType json noremap <buffer> <c-q> :call JsonBeautify()<cr>
"  autocmd FileType jsx noremap <buffer> <c-q> :call JsxBeautify()<cr>
"  autocmd FileType html noremap <buffer> <c-q> :call HtmlBeautify()<cr>
"  autocmd FileType gsp  noremap <buffer> <c-q> :call HtmlBeautify()<cr>
"  autocmd FileType css noremap <buffer> <c-q> :call CSSBeautify()<cr>
"  
:command! -nargs=0 Jumps :call Jumps()
function Jumps()
    let line = getline(".")
    let result = system(g:script_dir . "extractfile " . line)
    echo result
    "execute "sp " . result
endfunction

:command! -nargs=1 Mkdir :call Mkdir(<f-args>)
function Mkdir(dirname)
    let result2 = system("mkdir -p " . a:dirname)
    let result  = system("ls -lt ")
    echo result
endfunction

:command! -nargs=1 Rm :call Rm(<f-args>)
function Rm(dirname)
    let result2 = system("rm -rf " . a:dirname)
    let result  = system("ls -lt ")
    echo result
endfunction

:command! -nargs=0 Jump :call Jumpv()
function Jumpv()
    let line = getline(".")
    let result = system(g:script_dir . "extractfile " . line)
    execute "vsp " . result
endfunction

let script_dir = "~/.vim/scripts/"

:command! -nargs=? Randopen :call Randopen(<f-args>)
function! Randopen(...)
    if a:0 >= 1
        let result = system(g:script_dir . "randomfile " . a:1)
    else
        let result = system(g:script_dir . "randomfile ")
    endif
    execute "edit " . result
endfunction

:command! -nargs=? Ranobj :call Ranobj(<f-args>)
function! Ranobj(...)
    let result = system("ranobj")
    execute "edit " . result
endfunction

:command! -nargs=? Ranexs :call Ranexs(<f-args>)
function! Ranexs(...)
    let result = system("ranexs")
    execute "edit " . result
endfunction

:command! -nargs=1 Move :call Move(<f-args>)
function Move(newname)
    execute ":f " . a:newname . "|call delete(expand('#'))"
endfunction

:command! Delete :call delete(expand('#'))

:command! -nargs=0 Kj :call Kj()
function Kj()
    execute ":e ~/.vim/keikun.vim/bible.txt" 
endfunction

:command! -nargs=0 Remove :call Remove()
function Remove()
    let result = system("rm " . @%)
endfunction
 
:command! -nargs=0 Crack :call Crack()
function Crack()
    let result = system("otool -tvV " . @% . " | pbcopy")
endfunction

:command! -nargs=0 Cnv :call Cnv()
function Cnv()
   let result = system("cnv " . expand("<cword>"))
   echo result
endfunction
 
:command! -nargs=0 Filename :call Filename()
function Filename()
    let result = system("echo " . @% . " | pbcopy")
endfunction
  
"
" Unix
"
command! Sleep call Sleep() 
function! Sleep()
    let file = @%
    let result = system("pmset sleepnow")
endfunction

command! Cf call Cfind() 
function! Cfind()
    let file = @%
    let result = system(g:script_dir . "header-to-cpp " . file)
    execute "edit! " . result
endfunction

" Screen Capture
:command Screen :call Screen()
function! Screen()
    let result = system("screencapture ~/Desktop/pic.png")
endfunction

" Br
:command Br :call Br()
function! Br()
    let result = system("git branch")
    echo "\n" . result
endfunction


" Ls
:command Ls :call Ls()
function! Ls()
    let result = system("ls")
    echo "\n" . result
endfunction

" Tree
:command Tree :call Tree()
function! Tree()
    let result = system("tree")
    echo "\n" . result
endfunction

command! -nargs=1 Touchhere call Touchhere(<f-args>) 
function! Touchhere(filename)
    let fn = a:filename
    let ffn = expand("%:h") . '/' . fn
    e ffn
endfunction

command! -nargs=1 Touch call Touch(<f-args>) 
function! Touch(file)
    let result = system("touch " . a:file)
endfunction

" Cat
:command! -nargs=1 Cat :call Cat(<f-args>)
function! Cat(file)
    let result = system("cat " . a:file)
    echo result
endfunction

" ps aux | grep ...
:command! -nargs=1 PsAuxGrep :call PsAuxGrep(<f-args>)
function! PsAuxGrep(procquery)
    let result = system("ps aux | grep " . a:procquery)
    echo result
endfunction

command! Cx call Cx() 
function! Cx()
    let file   = @%
    let result = system("chmod +x " . file)
    echo result
endfunction

"
" Run myself
"
command! -nargs=? Runinter call Runinter(<f-args>) 
function! Runinter(...)
    let postfix = ""
    if a:0 >= 1
        let postfix = a:1
    end
    
    let file   = @%
    let result = system("chmod +x " . file)
    :! "" . file
endfunction

"
" Run myself
"
command! -nargs=0 Run call Run() 
function! Run()
    let file   = @%
    let result = system("chmod +x " . file)
    let result = system(file)
    echo result
endfunction

:command! Top :call Top()
function! Top()
    let result = system("top -o cpu")
    echo result
endfunction

:command! -nargs=? Localhost :call Localhost(<f-args>)
function! Localhost(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = ":" . a:1
    endif
    let result = system("open http://127.0.0.1" . alphaquery)
endfunction

:command! -nargs=1 KillPort :call KillPort(<f-args>)
function! KillPort(port)
    let result = system("sudo lsof -n -i4TCP:" . a:port . " | grep LISTEN | awk '{print $2}' | sudo xargs kill -9;")
    echo result
    echo "Port removed"
endfunction

"
" This works only if 'dict' command is defined in your OS.
"
:command! -nargs=? Dic :call Dic(<f-args>)
function! Dic(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    let result = system("dict " . expand("<cword>") . alphaquery)
    echo result
endfunction

:command! -nargs=0 Markdown :call Markdown()
function! Markdown()
    :! sugamd.py % | less -R
endfunction

:command! -nargs=? Sed :call Sed(<f-args>)
function! Sed(...)
    if a:0 >= 1
        let result = system("ope -r " . a:1 )
        echo result
    else
    endif
endfunction

"
" Bookmark
"
command! L8           call WebOpen("localhost:8000")
command! Ins          call system(g:script_dir . "ins o")
command! Ctags        call system("ctags -R .")
command! Gmail        call WebOpen("mail.google.com/mail/u/1/?pli=1#inbox")
command! Twitter      call WebOpen("twitter.com/tobasojyo")
command! Twitternew   call WebOpen("twitter.com/compose/tweet")
command! Securitynews call WebOpen("www.scmagazine.com/home/security-news/")
command! Hackernews   call WebOpen("news.ycombinator.com")
command! Atmarkit     call WebOpen("www.atmarkit.co.jp/ait/subtop/features/special/")
command! Task         call WebOpen("calendar.google.com/calendar/b/1/r")
command! Youtube      call WebOpen("youtube.com")
command! Netflix      call WebOpen("www.netflix.com/browse") 
command! Sugawiki     call WebOpen("bitbucket.org/keisugano/personal-wiki/src/master/") 
command! Bible        call WebOpen("www.chinesebibleonline.com") 
command! Hub          call WebOpen("employment.en-japan.com/engineerhub/")
command! Forbes       call WebOpen("www.forbes.com")
command! File         call File()
command! Xxd          call Xxd()
command! Url          call Url()
:command! -nargs=? Baidu :call Baidu(<f-args>)
command! Lf :%s/,/,\r/g

:command! -nargs=0 Xxd :call Xxd()
function! Xxd()
    let xxdfile = @% . ".xxd"
    let result = system("xxd -b " . @%. ' > ' . xxdfile)
    exe 'edit ' . xxdfile
endfunction

:command! -nargs=0 Hex :call Hex()
function! Hex()
    let result = system("16 " . expand("<cword>"))
    echo result
endfunction

:command! -nargs=0 Decidump :call Decidump()
function! Decidump()
    let decifile = @% . ".de"
    let result = system("decidump " . @% . ' > ' . decifile)
    exe 'edit ' . decifile
endfunction
 
:command! -nargs=0 Hexdump :call Hexdump()
function! Hexdump()
    let hexfile = @% . ".16"
    let result = system("hexdump -C " . @%. ' > ' . hexfile)
    exe 'edit ' . hexfile
endfunction
  
function! File()
    let result = system("file " . @%)
    echo result
endfunction

function! Url()
    let line=getline('.')
    let result = system("open " . getline('.'))
    echo result
endfunction

function! Baidu(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '%20', "g")
    endif
    let result = system("open https://www.baidu.com/s?wd=" . expand("<cword>") . alphaquery)
endfunction

:command! -nargs=? Ww :call LookFree(<f-args>)
function! LookFree(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    execute ':!' . "open \"https://www.google.com/search?q=" . alphaquery . "\""
endfunction

:command! -nargs=? Lw :call LookFree2(<f-args>)
function! LookFree2(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    execute ':!' . "w3m \"https://www.google.com/search?q=" . alphaquery . "&hl=en\""
endfunction

:command! -nargs=? We :call Look(<f-args>)
function! Look(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    execute ":! open 'https://www.google.com/search?q=" . expand("<cword>") . alphaquery . "'"
endfunction

:command! -nargs=? WeMore :call Xlook(<f-args>)
function! Xlook(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    let result = system("open https://www.google.com/search?q=" . expand("<cWORD>") . alphaquery)
endfunction

command! Whatis call WhatIs() 
function! WhatIs()
    let result = system("open https://www.google.com/search?q=what+is+" . expand("<cword>"))
endfunction

command! Link call Link() 
function! Link()
    let result = system("open " . expand("<cWORD>"))
endfunction

:command! -nargs=? Lynx :call W3mopen(<f-args>)
function! W3mopen(...)
    let alphaquery = ""
    if a:0 >= 1
        let alphaquery = "+" . substitute(a:1, ' ', '+', "g")
    endif
    execute ':!' . "lynx https://www.google.com/search?q=" . expand("<cword>") . alphaquery . '&hr=lang_lt&hl=en'
endfunction


function! WebOpen(...)
    let result = system("open https://" . a:1)
endfunction

command! DockerBuild call DockerBuild() 
function! DockerBuild()
    let result = system("docker build .")
    echo result
endfunction

iabbrev teh the
iabbrev hte the
iabbrev trturn return
iabbrev rerurn return
iabbrev returen return
iabbrev taht that

" Git
"
" Operates Git related commands
"
command! Ph           call Git("push origin HEAD")
command! Githubnew    call WebOpen("github.com/new")
command! Github       call WebOpen("github.com/keitaroemotion?tab=repositories")
command! Developers   call ShowDevelopers()

function! Git(...)
    let result = system("git " . a:1)
    echo result
endfunction

function! ShowDevelopers()
    let result = system("git shortlog -sne")
    echo "\nDevs are\n"
    echo result
endfunction

command! Githubthis call Githubthis()
function! Githubthis()
    let result = system("~/.vim/keikun.vim/scripts/githubthis")
endfunction

" Git reset hard
:command Grh :call GitResetHard()
function! GitResetHard()
    let result = system("git reset --hard")
endfunction

" Git clean -f
:command Gcf :call GitCleanF()
function! GitCleanF()
    let result = system("git clean -f")
    echo result
endfunction

" Git status
:command St :call GitStatus()
function! GitStatus()
    let result = system("git status")
    echo result
endfunction

"
" Git add
:command! -nargs=? Add :call Add(<f-args>)
function! Add(...)
    if a:0 >= 1
        let result = system("git add " . a:file)
    else
        let result = system("git add " . @%)
    end
    echo result
    let result = system("git status")
    echo result 
endfunction

" Git reset
:command Reset :call Reset()
function! Reset()
    let result = system("git reset")
    echo result
endfunction

" Git commit
:command! -nargs=? Adp :call Adp(<f-args>)
function! Adp(...)
    if a:0 >= 1
        let result = system("git add .; git commit -m \"" . a:1 . "\"; git push origin HEAD")
        echo result
    else
        :! git add .
        :! git commit --verbose
        :! git push origin HEAD
    end
endfunction

" Git commit
:command! -nargs=? Commit :call Commit(<f-args>)
function! Commit(...)
    if a:0 >= 1
        let result = system("git commit -m \"" . a:1 . "\"")
        echo result
    else
        :! git commit
        "let result = system("git commit -m " . "XXX")
    end
endfunction

" Git log
:command! -nargs=? Log :call Log(<f-args>)
function! Log(...)
    if a:0 >= 1
        let result = system("git log " . a:1)
        echo result
    else
        let result = system("git log ")
        echo result
    end
endfunction

command Lgit   :vert term ++close lazygit 
command! Diff call Diff() 
function! Diff()
    let result = system("git diff ")
    echo result
endfunction

command! Cached call Cached() 
function! Cached()
    let result = system("git diff --cached ")
    echo result
endfunction

"
" HTML
"
:command! SortCss :call SortCss()
function! SortCss()
    let result = system(g:script_dir . "css_formatter " . @%)
    echo result
    :e!
endfunction

command! ConfWifi call ConfWifi()
function! ConfWifi()
    :e ~/.vim/keikun.vim/secrets/wifi.txt
endfunction

function! SourceVim()
    :source ~/.vimrc
endfunction

command! README call README()
function! README()
    :e README.md
endfunction

let g:spf13_no_autochdir = 0

nnoremap s :w<CR>
nnoremap <C-g> :execute ":! open 'https://www.google.com/search?q=" . expand("<cword>") . "'"<CR>

"nnoremap <C-j> :e **/ . expand("<cword>")
nnoremap <C-j> :execute ":! fd " . expand("<cword>")<CR>


nnoremap L :Lw<Space>

"
" Layout
"
hi CursorLine    cterm=NONE ctermbg=254 ctermfg=black guibg=NONE guifg=black
"hi CursorLine   cterm=NONE ctermbg=231 ctermfg=darkmagenta guibg=NONE guifg=black
"hi CursorLine   cterm=underline gui=underline ctermfg=NONE guibg=NONE guifg=black
"hi CursorColumn cterm=NONE ctermbg=white ctermfg=white guibg=white guifg=white
"nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>
"augroup CursorLine
"  au!
"  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
"  au WinLeave * setlocal nocursorline
"augroup END

:command! -nargs=? Css :call Css(<f-args>)
function Css(...)
    if a:0 >= 1
        echo
        let result = system(g:script_dir . "cssfinder " . a:1)
        echo result
    endif
endfunction

"command! Hx call Hex() 
"function! Hex()
"    let result = system(g:script_dir . "hex2digit " . expand("<cword>"))
"    echo result
"endfunction
  
:command! -nargs=0 Wifi :call Wifi()
function! Wifi()
    let result = system(expand("~/.vim/keikun.vim/scripts/wifi"))
    echo result
endfunction

:command! -nargs=? Shebang :call Shebang(<f-args>)
function! Shebang(...)
    if a:0 >= 1
        let text = "#!/usr/bin/env " . a:1
        put =text
    else
    end
endfunction

:command! -nargs=0 Print :call Print()
function! Print()
    let text = "println(\"${}\")" 
    put =text
endfunction

command! PyEnc call PyEnc() 
function! PyEnc(...)
    let text = "# -*- coding: utf-8 -*-"
    put =text
endfunction

command! Umltemp call Umltemp() 
function! Umltemp()
    let text = "@startuml\n\nskinparam monochrome true\nskinparam shadowing false\n\n@enduml"
    put =text
endfunction

:command! -nargs=? Memoadd :call Memoadd(<f-args>)
function! Memoadd(...)
    let message = ''
    if a:0 >= 1
        let message = a:1
    endif
    let current_file_path = @%
    let current_number    = line(".") 
    let current_content   = getline(".") 
    let cmd = g:script_dir . "memo --write \"" . current_number . '|' . current_file_path . '|' . current_content . "\""
    echo cmd
    let result = system(cmd)
    echo "\n------ ADDED! -------\n"
    echo result
endfunction

:command! -nargs=0 Memos :call Memos()
function! Memos()
    let cmd    = g:script_dir . "memo --list"
    let result = system(cmd)
    echo "\n------ MEMOS -------\n"
    echo result
endfunction

:command! -nargs=? Memopen :call Memoread(<f-args>)
function! Memoread(...)
    let message = ""
    if a:0 >= 1
        let message = a:1
        let cmd             = g:script_dir . "memo --read " . message
        let result          = system(cmd)
        let filename_number = split(result, " ")
        let l:filename      = filename_number[0]
        let l:number        = filename_number[1]
        execute 'edit ' . l:filename
        execute '' . l:number
    else
        echo "\nChoose one:\n\n"
        Memos
    endif
endfunction

:command! -nargs=1 Nmap :call Nmap(<f-args>)
function! Nmap(url)
    let result = system("nmap " . a:url)
    echo result
endfunction

:command! -nargs=? NmapCword :call NmapCword(<f-args>)
function! NmapCword(...)
    let port = ""
    if a:0 >= 1
        let port = ":" . a:1
    end
    let url = substitute(expand("<cWORD>"), 'http://', '', 'g')
    let result = system("nmap " . url . port)
    echo result
endfunction

:command! -nargs=1 Curl :call Curl(<f-args>)
function! Curl(url)
    let result = system("curl " . a:url)
    echo result
endfunction

:command! -nargs=1 Curlv :call Curlv(<f-args>)
function! Curlv(url)
    let result = system("curl -v " . a:url)
    echo result
endfunction

:command! -nargs=? CurlCword :call CurlCword(<f-args>)
function! CurlCword(...)
    let port = ""
    if a:0 >= 1
        let port = ":" . a:1
    end
    let result = system("curl " . expand("<cWORD>") . port)
    echo result
endfunction

:command! -nargs=? CurlCwordv :call CurlCwordv(<f-args>)
function! CurlCwordv(...)
    let port = ""
    if a:0 >= 1
        let port = ":" . a:1
    end
    let result = system("curl -v " . expand("<cWORD>") . port)
    echo result
endfunction

:command! -nargs=? Open :call Open(<f-args>)
function! Open(...)
    let result = system("open " . @%)
endfunction

:command! -nargs=0 Now :call Now(<f-args>)
function! Now()
    let result = system("date")
    echo result
endfunction

:command! -nargs=0 Tables :call Tables()
function! Tables(...)
    execute 'edit ' . g:wikidir . 'database.md'
endfunction

function! Repeat()
    let times = input("Count: ")
    let char  = input("Char: ")
    exe ":normal a" . repeat(char, times)
endfunction

imap <C-u> <C-o>:call Repeat()<cr>

:command! -nargs=0  Json :%!python -m json.tool
:command! -nargs=?  Msq :call Msq(<f-args>)
:command! -nargs=0  Sql :call OpenSys(g:script_dir . "msq ~/.myst/staging \"" . getline(".") . "\"")
:command! -nargs=?  Que :call Que(<f-args>)

function! Que(...) 
    if a:0 >= 1
        echo "------------------------------------"
        echo a:1
        echo "------------------------------------"
        let cmd = g:script_dir . "msq ~/.myst/staging \"" . a:1 . "\""
        let result = system(cmd)
        echo result
    else
        let cmd = g:script_dir . "msq ~/.myst/staging \"select * from " . expand("<cword>") . "\""
        echo cmd
        let result = system(cmd)
        echo result
    endif
endfunction

function! Msq(...)
  if a:0 >= 1
    echo "------------------------------------"
    echo a:1
    echo "------------------------------------"
    let result = system("msq ~/.myst/staging \"" . a:1 . "\"")
    echo result
  else
    echo "you need query"
  end
endfunction

function! OpenSys(cmd)
    echo "------------------------------------"
    echo a:cmd
    echo "------------------------------------"
    let result = system(a:cmd)
    echo result
endfunction

:set wildignore+=**/*class,**/*.png,**/*.jpg,build/**,**/*.hi

:highlight LineNr ctermfg=black

hi Comment    cterm=None ctermbg=None ctermfg=Gray 
hi Statement  cterm=None ctermbg=None ctermfg=Gray 
hi Identifier cterm=None ctermbg=None ctermfg=Gray
hi Type       cterm=None ctermbg=None ctermfg=Gray
hi PreProc    cterm=None ctermbg=None ctermfg=Gray
hi Constant   cterm=None ctermbg=None ctermfg=Gray
hi Normal     cterm=None ctermbg=None ctermfg=None
hi Special    cterm=None ctermbg=None ctermfg=Gray
hi Cursor     cterm=None ctermbg=None ctermfg=Gray

hi! Visual  ctermfg=Black ctermbg=154 cterm=none
set tags=tags

:command! -nargs=? Xs :call Xs(<f-args>)
function Xs(...)
    if a:0 >= 1
        execute ':!' . a:1 . ' ' . @%
    else
        echo 'no command found'
    endif
endfunction
set runtimepath^=~/.vim/bundle/ag

:command! -nargs=0 Count :call Count()
function! Count()
    let result = system("wc -m " . @%)
    echo result
endfunction
