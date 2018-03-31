" =============================================================================
" File:          autoload/ctrlp/help.vim
" Description:   CtrlP extension for vim help tags
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['help']
"
" Where 'help' is the name of the file 'help.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Load guard
if ( exists('g:loaded_ctrlp_help') && g:loaded_ctrlp_help )
  \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_help = 1


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#help#init()',
  \ 'accept': 'ctrlp#help#accept',
  \ 'lname': 'help',
  \ 'sname': 'hlp',
  \ 'type': 'tabs',
  \ 'enter': 'ctrlp#help#enter()',
  \ 'exit': 'ctrlp#help#exit()',
  \ 'opts': 'ctrlp#help#opts()',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#help#init()
  if get(g:, 'ctrlp_use_caching')
    let cachedir = ctrlp#utils#cachedir() . ctrlp#utils#lash() . 'hlp'
    let cachefile = cachedir . ctrlp#utils#lash() . 'cache.txt'
    if getftime(cachefile) > max(map(s:gettagsfiles(), 'getftime(v:val)'))
      return readfile(cachefile)
    else
      let input = s:getlist()
      call ctrlp#utils#writecache(input, cachedir, cachefile)
      return input
    endif
  endif

  return s:getlist()
endfunction

function! s:getlist()
  let tagsfiles = s:gettagsfiles()

  let input_dict = {}
  for tagsfile in tagsfiles
    for line in readfile(tagsfile)
      let line_dict = {matchstr(line, '^[^\t]\+') : line}
      call extend(input_dict, line_dict, "keep")
    endfor
  endfor
  call filter(input_dict, 'v:key !~ "^!_TAG_"')
  let input = sort(values(input_dict))

  return input
endfunction

function! s:gettagsfiles() "{{{
  let tagspaths = []
  for lang in split(&helplang, ",")
    if "en" != lang
      call add(tagspaths, "/doc/tags-" . lang)
    endif
  endfor
  call add(tagspaths, "/doc/tags")

  let tagsfiles = []
  for tagspath in tagspaths
    call extend(tagsfiles, filter(map(split(&rtp, ","), 'v:val . tagspath'), 'filereadable(v:val)'))
  endfor

  return tagsfiles
endfunction "}}}


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#help#accept(mode, str)
  call ctrlp#exit()
  let name = get(split(a:str, "\t"), 0)
  if ("v" == a:mode || "v" == g:ctrlp_help_default_mode) && "h" != a:mode
    exe g:ctrlp_help_vsplit_direction . " vertical help " . name
    exe "vertical resize " . g:ctrlp_help_vsplit_width
  elseif ( "t" == a:mode || ("e" == a:mode && "t" == g:ctrlp_help_default_mode))
    exe "tab help " . name
  else
    exe "noautocmd help " . name
  endif
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#help#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#help#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#help#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#help#id()
  return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/help.vim
" command! CtrlPHelp call ctrlp#init(ctrlp#help#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
