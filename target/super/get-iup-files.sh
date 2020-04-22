#!/bin/sh

# GNU/Linux files

# .a and .so files
wget 'https://sourceforge.net/projects/iup/files/3.28/Linux%20Libraries/iup-3.28_Linux50_64_lib.tar.gz'
wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Linux%20Libraries/im-3.13_Linux415_64_lib.tar.gz'
wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Linux%20Libraries/cd-5.12_Linux44_64_lib.tar.gz'

# Get the Windows files

# .a and .dll files
wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Static/iup-3.28_Win64_mingw6_lib.zip'
wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Dynamic/iup-3.28_Win64_dllw6_lib.zip'

wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Dynamic/im-3.13_Win64_dllw6_lib.zip'
wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Static/im-3.13_Win64_mingw6_lib.zip'

wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Dynamic/cd-5.12_Win64_dllw6_lib.zip'
wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Static/cd-5.12_Win64_mingw6_lib.zip'
