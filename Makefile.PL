use inc::Module::Install 1.00;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/WWW/Wikipedia.pm > README' );
}

perl_version '5.006';

name 'WWW-Wikipedia';
all_from 'lib/WWW/Wikipedia.pm';

requires 'LWP::UserAgent';
requires 'URI';
requires 'Text::Autoformat';

test_requires 'Test::More';

install_script 'bin/wikipedia';

repository 'http://github.com/edsu/www-wikipedia';

WriteAll;
