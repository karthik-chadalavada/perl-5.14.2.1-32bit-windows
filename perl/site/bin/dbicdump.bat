@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!/usr/bin/perl
#line 15

=head1 NAME

dbicdump - Dump a schema using DBIx::Class::Schema::Loader

=head1 SYNOPSIS

  dbicdump [-o <loader_option>=<value> ] <schema_class> <connect_info>

Examples:

  $ dbicdump -o dump_directory=./lib \
    -o components='["InflateColumn::DateTime"]' \
    MyApp::Schema dbi:SQLite:./foo.db '{ quote_char => "\"" }'

  $ dbicdump -o dump_directory=./lib \
    -o components='["InflateColumn::DateTime"]' \
    -o preserve_case=1 \
    MyApp::Schema dbi:mysql:database=foo user pass '{ quote_char => "`" }'

On Windows that would be:

  $ dbicdump -o dump_directory=.\lib ^
    -o components="[q{InflateColumn::DateTime}]" ^
    -o preserve_case=1 ^
    MyApp::Schema dbi:mysql:database=foo user pass "{ quote_char => q{`} }"

=head1 DESCRIPTION

Dbicdump generates a L<DBIx::Class> schema using
L<DBIx::Class::Schema::Loader/make_schema_at> and dumps it to disk.

You can pass any L<DBIx::Class::Schema::Loader::Base> constructor option using
C<< -o <option>=<value> >>. For convenience, option names will have C<->
replaced with C<_> and values that look like references or quote-like
operators will be C<eval>-ed before being passed to the constructor.

The C<dump_directory> option defaults to the current directory if not
specified.

=head1 SEE ALSO

L<DBIx::Class::Schema::Loader>, L<DBIx::Class>.

=head1 AUTHOR

Dagfinn Ilmari Manns�ker C<< <ilmari@ilmari.org> >>

=head1 CONTRIBUTORS

Caelum: Rafael Kitover <rkitover@cpan.org>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

use strict;
use warnings;
use Getopt::Long;

use Pod::Usage;

use DBIx::Class::Schema::Loader qw/ make_schema_at /;
require DBIx::Class::Schema::Loader::Base;

my $loader_options;

GetOptions( 'loader-option|o=s%' => \&handle_option );
$loader_options->{dump_directory} ||= '.';

my ($schema_class, @loader_connect_info) = @ARGV
    or pod2usage(1);

my $dsn = shift @loader_connect_info;

my ($user, $pass) = $dsn =~ /sqlite/i ? ('', '')
    : splice @loader_connect_info, 0, 2;

my @extra_connect_info_opts = map parse_value($_), @loader_connect_info;

make_schema_at(
    $schema_class,
    $loader_options,
    [ $dsn, $user, $pass, @extra_connect_info_opts ],
);

exit 0;

sub parse_value {
    my $value = shift;

    $value = eval $value if $value =~ /^\s*(?:sub\s*\{|q\w?\s*[^\w\s]|[[{])/;

    return $value;
}

sub handle_option {
    my ($self, $key, $value) = @_;

    $key =~ tr/-/_/;
    die "Unknown option: $key\n"
        unless DBIx::Class::Schema::Loader::Base->can($key);

    $value = parse_value $value;

    $loader_options->{$key} = $value;
}

1;

__END__

__END__
:endofperl
