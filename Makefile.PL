use inc::Module::Install 0.68;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/WWW/Wikipedia.pm > README' );
}

name 'WWW-Wikipedia';
all_from 'lib/WWW/Wikipedia.pm';

requires 'LWP::UserAgent';
requires 'CGI';
requires 'Text::Autoformat';

test_requires 'Test::More';

install_script 'bin/wikipedia';

auto_install;
WriteAll;
