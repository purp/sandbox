setenv EDITOR 'mate -w'
setenv PATH ./script:~/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:$PATH
setenv PYTHONPATH ~/lib/python

# Config for workdir_cd
setenv WORKDIR ~/work
setenv WCD_DIRS "$WORKDIR $WORKDIR/linkedin $WORKDIR/linkedin/*repo/* $WORKDIR/cucina"

# Config for QT
setenv QTDIR /Developer/qt
setenv PATH $QTDIR/bin:$PATH

if ($?DYLD_LIBRARY_PATH) then
  setenv DYLD_LIBRARY_PATH $QTDIR/lib:$DYLD_LIBRARY_PATH
else
  setenv DYLD_LIBRARY_PATH $QTDIR/lib
endif

# Add manpages for MacPorts
if ($?MANPATH) then
  setenv MANPATH /opt/local/man:$MANPATH
else
  setenv MANPATH /opt/local/man:/usr/local/mysql/man:`man --path`
endif

set optional_dotfiles = (~/.aliases ~/.complete ~/.lscolors ~/.aws_info)
foreach file ($optional_dotfiles)
  if (-r ${file}) then
    source ${file}
  endif
end

setenv LESS '-R'

set ellipsis = '/.../'
set promptchars = ">#"
set prompt = "%B%n@%m%b:%c02 [%T] <%h%# "
